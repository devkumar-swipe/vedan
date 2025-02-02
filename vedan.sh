#!/bin/bash

# Tool Information
TOOL_NAME="Vedan-Bug Bounty Toolkit"
VERSION="1.0"
AUTHOR="Ved Kumar"
CONTACT_EMAIL="devkumarmahto204@outlook.com"
GITHUB_REPO="https://github.com/devkumar-swipe/vedan"
BANNER="============================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output directory
OUTPUT_DIR="$HOME/vedan"
LOG_FILE="$OUTPUT_DIR/bug_bounty_tool.log"

# Function to display the header
header() {
  echo -e "${GREEN}$BANNER"
  echo -e "${BLUE}$TOOL_NAME"
  echo -e "${YELLOW}Version: $VERSION"
  echo -e "Author: $AUTHOR"
  echo -e "Contact: $CONTACT_EMAIL"
  echo -e "GitHub: $GITHUB_REPO"
  echo -e "${GREEN}$BANNER${NC}"
}

# Function to log messages
log() {
  local message="$1"
  echo -e "${BLUE}[*]${NC} $message" | tee -a "$LOG_FILE"
}

# Function to log errors
error() {
  local message="$1"
  echo -e "${RED}[!]${NC} $message" | tee -a "$LOG_FILE"
  exit 1
}

# Function to display help
help_menu() {
  header
  echo -e "${YELLOW}Usage:${NC}"
  echo -e "  ./vedan.sh [OPTIONS]"
  echo -e "\n${YELLOW}Options:${NC}"
  echo -e "  -d, --domain    Target domain (e.g., example.com)"
  echo -e "  -h, --help      Display this help menu"
  echo -e "\n${YELLOW}Example:${NC}"
  echo -e "  ./vedan.sh -d example.com"
  echo -e "${GREEN}$BANNER${NC}"
  exit 0
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
  local dependencies=("subfinder" "amass" "filter-resolved" "httprobe" "waybackurls" "kxss")
  for cmd in "${dependencies[@]}"; do
    if ! command_exists "$cmd"; then
      error "Command $cmd not found. Please install it using the instructions in requirements.txt."
    fi
  done
}

# Function to create output directory
create_output_dir() {
  if [[ ! -d "$OUTPUT_DIR" ]]; then
    log "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR" || error "Failed to create output directory!"
  fi
}

# Function to validate domain format
validate_domain() {
  local domain="$1"
  if [[ ! "$domain" =~ ^([a-zA-Z0-9][a-zA-Z0-9-]*\.)+[a-zA-Z]{2,}$ ]]; then
    error "Invalid domain format. Please provide a valid domain (e.g., example.com)."
  fi
}

# Function to run the tool
run_tool() {
  local domain="$1"
  local subfinder_output="$OUTPUT_DIR/domains_subfinder_$domain.txt"
  local amass_output="$OUTPUT_DIR/domains_$domain.txt"
  local resolved_output="$OUTPUT_DIR/domains_$domain_resolved.txt"
  local xss_output="$OUTPUT_DIR/xss_$domain.txt"

  log "Starting scan for domain: $domain"

  # Run subfinder
  log "Running subfinder..."
  subfinder -d "$domain" -o "$subfinder_output" || error "Subfinder failed!"

  # Run amass
  log "Running amass..."
  amass enum --passive -d "$domain" -o "$amass_output" || error "Amass failed!"

  # Combine results
  log "Combining results..."
  cat "$subfinder_output" | tee -a "$amass_output" || error "Failed to combine results!"

  # Filter resolved domains
  log "Filtering resolved domains..."
  if ! command_exists "filter-resolved"; then
    error "filter-resolved not found. Please install it or replace it with an alternative."
  fi
  cat "$amass_output" | filter-resolved | tee -a "$resolved_output" || error "Failed to filter resolved domains!"

  # Run httprobe, waybackurls, and kxss
  log "Running httprobe, waybackurls, and kxss..."
  cat "$resolved_output" | httprobe -p http:81 -p http:8080 -p https:8443 | waybackurls | kxss | tee "$xss_output" || error "Failed to run httprobe, waybackurls, or kxss!"

  log "Scan completed. Results saved in $xss_output"
  log "Thank you for using $TOOL_NAME! For support, contact $CONTACT_EMAIL or visit $GITHUB_REPO."
}

# Main script
main() {
  header

  # Parse arguments
  if [[ $# -eq 0 ]]; then
    help_menu
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--domain)
        DOMAIN="$2"
        shift 2
        ;;
      -h|--help)
        help_menu
        ;;
      *)
        error "Invalid argument: $1"
        ;;
    esac
  done

  # Check if domain is provided
  if [[ -z "$DOMAIN" ]]; then
    error "Domain not provided! Use -d or --domain to specify a target domain."
  fi

  # Validate domain format
  validate_domain "$DOMAIN"

  # Check dependencies
  check_dependencies

  # Create output directory
  create_output_dir

  # Run the tool
  run_tool "$DOMAIN"
}

# Execute the script
main "$@"
