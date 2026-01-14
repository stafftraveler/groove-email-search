#!/usr/bin/env node

/**
 * Groove API Email Fetcher
 *
 * Fetches emails from the Groove API based on search criteria
 * and extracts contact information
 *
 * Prerequisites:
 * - Node.js installed
 * - @inquirer/prompts package (npm install @inquirer/prompts)
 * - cli-progress package (npm install cli-progress)
 * - .env file with AUTH_TOKEN
 *
 * Usage:
 * node fetch_all_groove_emails.js
 *
 * Results will be saved to export/exported_contacts.json or export/exported_contacts.csv
 */

const https = require("https");
const fs = require("fs");
const path = require("path");
const cliProgress = require("cli-progress");

// Import inquirer
let select, input;
(async () => {
  try {
    const inquirer = await import("@inquirer/prompts");
    select = inquirer.select;
    input = inquirer.input;
  } catch (error) {
    console.error("\x1b[31mError: @inquirer/prompts not installed\x1b[0m\n");
    console.error("Please install it with:\n");
    console.error("  npm install @inquirer/prompts\n");
    process.exit(1);
  }
})();

// Colors for output
const colors = {
  green: "\x1b[32m",
  blue: "\x1b[34m",
  yellow: "\x1b[33m",
  cyan: "\x1b[36m",
  red: "\x1b[31m",
  reset: "\x1b[0m",
};

// Load .env file
const envPath = path.join(__dirname, ".env");
if (!fs.existsSync(envPath)) {
  console.error("\x1b[31mError: .env file not found\x1b[0m\n");
  console.error("Please create a .env file with your Groove API token:\n");
  console.error("  AUTH_TOKEN=your_token_here\n");
  console.error("See .env.example for a template");
  process.exit(1);
}

// Parse .env file
const envContent = fs.readFileSync(envPath, "utf8");
const envVars = {};
envContent.split("\n").forEach((line) => {
  const trimmed = line.trim();
  if (trimmed && !trimmed.startsWith("#")) {
    const [key, ...valueParts] = trimmed.split("=");
    if (key && valueParts.length > 0) {
      envVars[key.trim()] = valueParts.join("=").trim();
    }
  }
});

if (!envVars.AUTH_TOKEN) {
  console.error("\x1b[31mError: AUTH_TOKEN not found in .env file\x1b[0m\n");
  console.error("Please add your Groove API token to the .env file:\n");
  console.error("  AUTH_TOKEN=your_token_here\n");
  process.exit(1);
}

const CONFIG = {
  apiUrl: "api.groovehq.com",
  path: "/v2/graphql?_TicketConversationsQuery",
  authToken: envVars.AUTH_TOKEN,
  pageSize: 50,
  delayMs: 500,
  exportDir: path.join(__dirname, "export"),
};

// Ensure export directory exists
if (!fs.existsSync(CONFIG.exportDir)) {
  fs.mkdirSync(CONFIG.exportDir, { recursive: true });
}

// GraphQL Query for body text search
const GRAPHQL_QUERY_BODY = `query TicketConversationsQuery($filter: ConversationFilter, $orderBy: ConversationOrder, $cursor: String, $size: Int){
  conversations(filter: $filter, orderBy: $orderBy, after: $cursor, first: $size) {
    nodes {
      contact {
        id
        email
        firstName
        lastName
        name
      }
    }
    totalCount
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}`;

// GraphQL Query for tag search (with full fragments)
const GRAPHQL_QUERY_TAG = `
query TicketConversationsQuery($filter: ConversationFilter, $orderBy: ConversationOrder, $cursor: String, $size: Int){
  conversations(filter: $filter, orderBy: $orderBy, after: $cursor, first: $size) {
    nodes {

  ...conversationFragment
  ...widgetConversationFragment

    }
    totalCount
    totalPageCount
    pageInfo {
      hasNextPage
      hasPreviousPage
      endCursor
      startCursor
    }
  }
}

fragment conversationFragment on Conversation {
  __typename
  id
  assigned {
    agent {
      id
      name
      email
    }
    team {
      id
      name
    }
    at
  }
  channel {
    id
    color
  }
  contact {
    id
    avatarUrl
    email
    firstName
    lastName
    name
    lastSeenAt
    createdAt

  }



  drafts {
    edges {
      node {
        id
        agent {
          id
        }
        draftId
        draftType
        updatedAt
        version
        payload
        conversationId
        __typename
      }
    }
  }

  deletedAt
  number
  snoozed {
    by {
      id
    }
    until
  }
  starred
  state
  stateUpdatedAt
  summaryMessage {
    bodyPlainText
    isNote
    author {
      ... on Agent {
        id
      }
      ... on Contact {
        id
      }
    }
  }
  systemUpdatedAt
  updatedAt
  createdAt
  subject
  lastUnansweredUserMessageAt
  tags {
    nodes {
      id
      name
      color
    }
  }
  mentions {
    id
    agent {
      id
    }
  }
  counts {
    messages
    interactions
    attachments
  }
}

fragment widgetConversationFragment on WidgetConversation {
  ...conversationFragment
  browser
  pageTitle
  pageUrl
  platform
  referrer
}
`;

function convertToCSV(contacts) {
  const header = "firstName,lastName,email\n";
  const rows = contacts
    .map((contact) => {
      // Escape fields that contain commas or quotes
      const escapeField = (field) => {
        if (!field) return "";
        if (
          field.includes(",") ||
          field.includes('"') ||
          field.includes("\n")
        ) {
          return `"${field.replace(/"/g, '""')}"`;
        }
        return field;
      };

      return `${escapeField(contact.firstName)},${escapeField(
        contact.lastName
      )},${escapeField(contact.email)}`;
    })
    .join("\n");

  return header + rows;
}

function makeRequest(cursor, filter, queryId, graphqlQuery) {
  return new Promise((resolve, reject) => {
    const requestBody = JSON.stringify({
      query: graphqlQuery,
      _method: "POST",
      variables: {
        filter: filter,
        queryId: queryId,
        orderBy: {
          field: "LATEST_COLLABORATOR_COMMENT_AT",
          direction: "DESC",
        },
        cursor: cursor,
        size: CONFIG.pageSize,
      },
    });

    const options = {
      hostname: CONFIG.apiUrl,
      path: CONFIG.path,
      method: "POST",
      headers: {
        Authorization: `Bearer ${CONFIG.authToken}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(requestBody),
        "User-Agent":
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        Referer: "https://stafftraveler.groovehq.com/",
        DNT: "1",
      },
    };

    const req = https.request(options, (res) => {
      let data = "";

      res.on("data", (chunk) => {
        data += chunk;
      });

      res.on("end", () => {
        try {
          const json = JSON.parse(data);
          if (json.errors) {
            reject(new Error(`API Error: ${JSON.stringify(json.errors)}`));
          } else {
            resolve(json);
          }
        } catch (e) {
          reject(new Error(`Failed to parse JSON: ${e.message}`));
        }
      });
    });

    req.on("error", (e) => {
      reject(e);
    });

    req.write(requestBody);
    req.end();
  });
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchAllEmails(
  filter,
  queryId,
  searchDescription,
  graphqlQuery
) {
  const allContacts = [];
  let cursor = null;
  let pageCount = 0;
  let totalCount = 0;
  let totalPages = 0;
  let progressBar = null;

  console.log(`${colors.green}Starting to fetch emails...${colors.reset}\n`);

  try {
    while (true) {
      pageCount++;

      const response = await makeRequest(cursor, filter, queryId, graphqlQuery);

      if (!response.data || !response.data.conversations) {
        throw new Error("Unexpected response structure");
      }

      const conversations = response.data.conversations;
      const nodes = conversations.nodes || [];

      if (pageCount === 1) {
        totalCount = conversations.totalCount;
        totalPages = Math.ceil(totalCount / CONFIG.pageSize);
        console.log(
          `${colors.green}Total emails to fetch: ${totalCount}${colors.reset}`
        );
        console.log(
          `${colors.green}Total pages: ${totalPages}${colors.reset}\n`
        );

        // Initialize progress bar
        progressBar = new cliProgress.SingleBar({
          format:
            "Progress |" +
            colors.cyan +
            "{bar}" +
            colors.reset +
            "| {percentage}% | Page {value}/{total} | Contacts: {contacts}",
          barCompleteChar: "\u2588",
          barIncompleteChar: "\u2591",
          hideCursor: true,
        });
        progressBar.start(totalPages, 0, { contacts: 0 });
      }

      // Extract contact information
      for (const node of nodes) {
        if (node.contact) {
          allContacts.push({
            firstName: node.contact.firstName,
            lastName: node.contact.lastName,
            email: node.contact.email,
          });
        }
      }

      // Update progress bar
      if (progressBar) {
        progressBar.update(pageCount, { contacts: allContacts.length });
      }

      // Check if there are more pages
      const hasNextPage = conversations.pageInfo.hasNextPage;
      cursor = conversations.pageInfo.endCursor;

      if (!hasNextPage) {
        if (progressBar) {
          progressBar.stop();
        }
        console.log(`\n${colors.green}✓ All emails fetched!${colors.reset}`);
        break;
      }

      // Small delay to avoid rate limiting
      await delay(CONFIG.delayMs);
    }
  } catch (error) {
    if (progressBar) {
      progressBar.stop();
    }
    console.error(`\n❌ Error: ${error.message}`);
    if (allContacts.length > 0) {
      console.log(
        `\nSaving ${allContacts.length} contacts that were fetched before the error...`
      );
    } else {
      throw error;
    }
  }

  return allContacts;
}

// Run the script
async function main() {
  // Wait for inquirer to be imported
  await new Promise((resolve) => setTimeout(resolve, 100));

  if (!select || !input) {
    console.error(
      `${colors.red}Error: Failed to load @inquirer/prompts${colors.reset}`
    );
    process.exit(1);
  }

  try {
    console.log("\n");
    console.log(
      `${colors.blue}========================================${colors.reset}`
    );
    console.log(`${colors.blue}Groove API Email Fetcher${colors.reset}`);
    console.log(
      `${colors.blue}========================================${colors.reset}`
    );
    console.log("");

    // Prompt for search type using inquirer
    console.log(`${colors.cyan}What do you want to search for?${colors.reset}`);
    const searchType = await select({
      message: "Choose search type:",
      choices: [
        { name: "Emails with text in the body", value: "body" },
        { name: "Emails tagged with a specific tag", value: "tag" },
      ],
    });

    let filter, queryId, searchDescription, graphqlQuery;

    if (searchType === "body") {
      console.log("");
      const searchQuery = await input({
        message: "Enter your search query:",
      });

      if (!searchQuery.trim()) {
        console.error(
          `${colors.yellow}Search query cannot be empty.${colors.reset}`
        );
        process.exit(1);
      }

      filter = { keywords: searchQuery };
      queryId = `type:mailbox orderBy:newestByCollaborator search:"${searchQuery}"`;
      searchDescription = `emails containing "${searchQuery}"`;
      graphqlQuery = GRAPHQL_QUERY_BODY;
      console.log(
        `${colors.green}Searching for emails containing: "${searchQuery}"${colors.reset}\n`
      );
    } else {
      console.log("");
      const tagName = await input({
        message: "Enter the tag name:",
      });

      if (!tagName.trim()) {
        console.error(
          `${colors.yellow}Tag name cannot be empty.${colors.reset}`
        );
        process.exit(1);
      }

      filter = { tagNames: [tagName] };
      queryId = `tag:"${tagName}" type:mailbox orderBy:newestByCollaborator`;
      searchDescription = `emails tagged with "${tagName}"`;
      graphqlQuery = GRAPHQL_QUERY_TAG;
      console.log(
        `${colors.green}Searching for emails tagged with: "${tagName}"${colors.reset}\n`
      );
    }

    // Prompt for export format using inquirer
    console.log(
      `${colors.cyan}How would you like to export the results?${colors.reset}`
    );
    const exportFormat = await select({
      message: "Choose export format:",
      choices: [
        { name: "JSON", value: "json" },
        { name: "CSV", value: "csv" },
      ],
    });

    const fileName =
      exportFormat === "json"
        ? "exported_contacts.json"
        : "exported_contacts.csv";
    const outputFile = path.join(CONFIG.exportDir, fileName);
    console.log(
      `${
        colors.green
      }Results will be exported as ${exportFormat.toUpperCase()}${
        colors.reset
      }\n`
    );

    // Fetch all emails
    const contacts = await fetchAllEmails(
      filter,
      queryId,
      searchDescription,
      graphqlQuery
    );

    console.log("");
    console.log(
      `${colors.blue}========================================${colors.reset}`
    );
    console.log(
      `${colors.green}Total contacts collected: ${contacts.length}${colors.reset}`
    );
    console.log(
      `${colors.blue}========================================${colors.reset}`
    );
    console.log("");

    // Save to file based on format
    if (exportFormat === "json") {
      fs.writeFileSync(outputFile, JSON.stringify(contacts, null, 2));
      console.log(
        `${colors.green}✓ Results saved to ${outputFile}${colors.reset}\n`
      );

      console.log(`${colors.blue}Preview (first 5 contacts):${colors.reset}`);
      console.log(JSON.stringify(contacts.slice(0, 5), null, 2));
    } else {
      const csvContent = convertToCSV(contacts);
      fs.writeFileSync(outputFile, csvContent);
      console.log(
        `${colors.green}✓ Results saved to ${outputFile}${colors.reset}\n`
      );

      console.log(`${colors.blue}Preview (first 5 contacts):${colors.reset}`);
      const lines = csvContent.split("\n").slice(0, 6);
      console.log(lines.join("\n"));
    }

    // Show statistics
    const uniqueEmails = new Set(contacts.map((c) => c.email)).size;
    console.log("");
    console.log(`${colors.blue}Statistics:${colors.reset}`);
    console.log(`Total contacts: ${contacts.length}`);
    console.log(`Unique emails: ${uniqueEmails}`);

    console.log("");
    console.log(
      `${colors.green}Done! Check ${outputFile} for the complete list.${colors.reset}`
    );
  } catch (error) {
    if (error.name === "ExitPromptError") {
      console.log(
        `\n${colors.yellow}Operation cancelled by user.${colors.reset}`
      );
      process.exit(0);
    }
    console.error(
      `\n${colors.red}❌ Fatal error: ${error.message}${colors.reset}`
    );
    process.exit(1);
  }
}

main();
