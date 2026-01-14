#!/bin/bash

##############################################################################
# Groove API Email Fetcher
#
# This script fetches emails from the Groove API based on search criteria
# and extracts contact information (firstName, lastName, email)
#
# Prerequisites:
# - curl (pre-installed on macOS)
# - jq (for JSON parsing) - install with: brew install jq
# - fzf (for interactive menus) - install with: brew install fzf
#
# Usage:
# 1. Make this script executable: chmod +x fetch_all_groove_emails.sh
# 2. Run it: ./fetch_all_groove_emails.sh
# 3. Use arrow keys to select options, Enter to confirm
# 4. Results will be saved to export/exported_contacts.json or export/exported_contacts.csv
##############################################################################

# Configuration
API_URL="https://api.groovehq.com/v2/graphql?_TicketConversationsQuery"
EXPORT_DIR="./export"

# Ensure export directory exists
mkdir -p "$EXPORT_DIR"

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}Error: .env file not found${NC}"
    echo ""
    echo "Please create a .env file with your Groove API token:"
    echo ""
    echo "  AUTH_TOKEN=your_token_here"
    echo ""
    echo "See .env.example for a template"
    exit 1
fi

# Verify AUTH_TOKEN is set
if [ -z "$AUTH_TOKEN" ]; then
    echo -e "${RED}Error: AUTH_TOKEN not found in .env file${NC}"
    echo ""
    echo "Please add your Groove API token to the .env file:"
    echo ""
    echo "  AUTH_TOKEN=your_token_here"
    echo ""
    exit 1
fi

# GraphQL Query for body text search
GRAPHQL_QUERY_BODY='query TicketConversationsQuery($filter: ConversationFilter, $orderBy: ConversationOrder, $cursor: String, $size: Int){
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
}'

# GraphQL Query for tag search (with full fragments)
GRAPHQL_QUERY_TAG='
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

'

# Initialize variables
CURSOR="null"
PAGE=0
ALL_CONTACTS="[]"
TEMP_DIR="./groove_temp_$$"
mkdir -p "$TEMP_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Groove API Email Fetcher${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Error: jq is not installed${NC}"
    echo "Please install jq with: brew install jq"
    exit 1
fi

# Check for fzf
if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}Error: fzf is not installed${NC}"
    echo "Please install fzf with: brew install fzf"
    exit 1
fi

# Prompt for search type using fzf
echo -e "${CYAN}What do you want to search for?${NC}"
search_options=("Emails with text in the body" "Emails tagged with a specific tag")
SEARCH_SELECTION=$(printf "%s\n" "${search_options[@]}" | fzf --prompt="Choose search type: " --height=40% --border --header="Use ↑↓ to navigate, Enter to select")

if [ -z "$SEARCH_SELECTION" ]; then
    echo -e "${YELLOW}No search type selected. Exiting.${NC}"
    exit 1
fi

# Get search query based on type
if [ "$SEARCH_SELECTION" == "Emails with text in the body" ]; then
    echo ""
    read -p "Enter your search query: " SEARCH_QUERY
    if [ -z "$SEARCH_QUERY" ]; then
        echo -e "${YELLOW}Search query cannot be empty.${NC}"
        exit 1
    fi
    SEARCH_MODE="body"
    GRAPHQL_QUERY="$GRAPHQL_QUERY_BODY"
    echo -e "${GREEN}Searching for emails containing: \"$SEARCH_QUERY\"${NC}"
else
    echo ""
    read -p "Enter the tag name: " TAG_NAME
    if [ -z "$TAG_NAME" ]; then
        echo -e "${YELLOW}Tag name cannot be empty.${NC}"
        exit 1
    fi
    SEARCH_MODE="tag"
    GRAPHQL_QUERY="$GRAPHQL_QUERY_TAG"
    echo -e "${GREEN}Searching for emails tagged with: \"$TAG_NAME\"${NC}"
fi

echo ""

# Prompt for export format using fzf
echo -e "${CYAN}How would you like to export the results?${NC}"
export_options=("JSON" "CSV")
EXPORT_SELECTION=$(printf "%s\n" "${export_options[@]}" | fzf --prompt="Choose export format: " --height=40% --border --header="Use ↑↓ to navigate, Enter to select")

if [ -z "$EXPORT_SELECTION" ]; then
    echo -e "${YELLOW}No export format selected. Exiting.${NC}"
    exit 1
fi

# Set output file and format
if [ "$EXPORT_SELECTION" == "JSON" ]; then
    OUTPUT_FILE="$EXPORT_DIR/exported_contacts.json"
    EXPORT_MODE="json"
    echo -e "${GREEN}Results will be exported as JSON${NC}"
else
    OUTPUT_FILE="$EXPORT_DIR/exported_contacts.csv"
    EXPORT_MODE="csv"
    echo -e "${GREEN}Results will be exported as CSV${NC}"
fi

echo ""

echo -e "${GREEN}Starting to fetch emails...${NC}"
echo ""

while true; do
  PAGE=$((PAGE + 1))
  echo -e "${BLUE}Fetching page $PAGE...${NC}"

  # Create the request body based on search mode
  if [ "$SEARCH_MODE" == "body" ]; then
    # Body text search
    REQUEST_BODY=$(jq -n \
      --arg query "$GRAPHQL_QUERY" \
      --arg searchQuery "$SEARCH_QUERY" \
      --argjson cursor "$CURSOR" \
      '{
        query: $query,
        _method: "POST",
        variables: {
          filter: {
            keywords: $searchQuery
          },
          queryId: ("type:mailbox orderBy:newestByCollaborator search:\"" + $searchQuery + "\""),
          orderBy: {
            field: "LATEST_COLLABORATOR_COMMENT_AT",
            direction: "DESC"
          },
          cursor: $cursor,
          size: 50
        }
      }')
  else
    # Tag search
    REQUEST_BODY=$(jq -n \
      --arg query "$GRAPHQL_QUERY" \
      --arg tagName "$TAG_NAME" \
      --argjson cursor "$CURSOR" \
      '{
        query: $query,
        _method: "POST",
        variables: {
          filter: {
            tagNames: [$tagName]
          },
          queryId: ("tag:\"" + $tagName + "\" type:mailbox orderBy:newestByCollaborator"),
          orderBy: {
            field: "LATEST_COLLABORATOR_COMMENT_AT",
            direction: "DESC"
          },
          cursor: $cursor,
          size: 50
        }
      }')
  fi

  # Make the request
  RESPONSE=$(curl -s "$API_URL" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -H "Content-Type: application/json" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    -H "Referer: https://stafftraveler.groovehq.com/" \
    -H "DNT: 1" \
    -d "$REQUEST_BODY")

  # Save response for debugging
  echo "$RESPONSE" > "$TEMP_DIR/response_$PAGE.json"

  # Check if request was successful
  if [ -z "$RESPONSE" ]; then
    echo -e "${YELLOW}Error: Empty response received${NC}"
    break
  fi

  # Check for errors in response
  ERROR=$(echo "$RESPONSE" | jq -r '.errors // empty')
  if [ ! -z "$ERROR" ]; then
    echo -e "${YELLOW}API Error: $ERROR${NC}"
    break
  fi

  # Extract data using jq
  TOTAL_COUNT=$(echo "$RESPONSE" | jq -r '.data.conversations.totalCount // 0')
  HAS_NEXT=$(echo "$RESPONSE" | jq -r '.data.conversations.pageInfo.hasNextPage')
  NEXT_CURSOR=$(echo "$RESPONSE" | jq -r '.data.conversations.pageInfo.endCursor')
  NODES_COUNT=$(echo "$RESPONSE" | jq -r '.data.conversations.nodes | length')

  if [ "$PAGE" -eq 1 ]; then
    echo -e "${GREEN}Total emails to fetch: $TOTAL_COUNT${NC}"
    TOTAL_PAGES=$(( ($TOTAL_COUNT + 49) / 50 ))
    echo -e "${GREEN}Total pages: $TOTAL_PAGES${NC}"
    echo ""
  fi

  # Extract contacts from this page
  if [ "$SEARCH_MODE" == "body" ]; then
    # Simple query format
    PAGE_CONTACTS=$(echo "$RESPONSE" | jq '[.data.conversations.nodes[].contact | {firstName, lastName, email}]')
  else
    # Tag query format (with full conversation fragment)
    PAGE_CONTACTS=$(echo "$RESPONSE" | jq '[.data.conversations.nodes[].contact | {firstName, lastName, email}]')
  fi

  # Merge with all contacts
  ALL_CONTACTS=$(echo "$ALL_CONTACTS" "$PAGE_CONTACTS" | jq -s 'add')

  CURRENT_COUNT=$(echo "$ALL_CONTACTS" | jq 'length')
  echo "Fetched $NODES_COUNT emails (Total so far: $CURRENT_COUNT/$TOTAL_COUNT)"

  # Check if there are more pages
  if [ "$HAS_NEXT" != "true" ]; then
    echo ""
    echo -e "${GREEN}✓ All emails fetched!${NC}"
    break
  fi

  # Update cursor for next iteration
  CURSOR="\"$NEXT_CURSOR\""

  # Small delay to avoid rate limiting
  sleep 0.5
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Total contacts collected: $(echo "$ALL_CONTACTS" | jq 'length')${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Save final results based on format
if [ "$EXPORT_MODE" == "json" ]; then
    echo "$ALL_CONTACTS" | jq '.' > "$OUTPUT_FILE"
    echo -e "${GREEN}✓ Results saved to $OUTPUT_FILE${NC}"
    echo ""

    # Show preview
    echo -e "${BLUE}Preview (first 5 contacts):${NC}"
    echo "$ALL_CONTACTS" | jq '.[:5]'
else
    # Export as CSV
    echo "firstName,lastName,email" > "$OUTPUT_FILE"
    echo "$ALL_CONTACTS" | jq -r '.[] | [.firstName, .lastName, .email] | @csv' >> "$OUTPUT_FILE"
    echo -e "${GREEN}✓ Results saved to $OUTPUT_FILE${NC}"
    echo ""

    # Show preview
    echo -e "${BLUE}Preview (first 5 contacts):${NC}"
    head -n 6 "$OUTPUT_FILE"
fi

# Show statistics
UNIQUE_EMAILS=$(echo "$ALL_CONTACTS" | jq '[.[].email] | unique | length')
echo ""
echo -e "${BLUE}Statistics:${NC}"
echo "Total contacts: $(echo "$ALL_CONTACTS" | jq 'length')"
echo "Unique emails: $UNIQUE_EMAILS"

# Clean up temp files
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}Done! Check $OUTPUT_FILE for the complete list.${NC}"
