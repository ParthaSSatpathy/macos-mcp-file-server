Project Brief: macOS MCP File Server
Project Overview
Building a macOS-focused MCP (Model Context Protocol) server that provides intelligent file system operations. This is a Swift-based server that exposes file management capabilities through the MCP protocol, allowing AI assistants to perform sophisticated file operations on macOS systems.
Core Objectives

Demonstrate MCP capabilities: Show how MCP can integrate with native macOS file system APIs
Provide practical utility: Create genuinely useful file management tools for macOS users
Showcase Swift on macOS: Leverage Swift's native macOS framework integration

Target MCP Capabilities to Implement
Tools (Primary Focus)

File Search Tool

Search files by name, content, type, size, date
Support regex patterns and complex queries
Return structured results with metadata


File Organization Tool

Auto-categorize files (by type, date, project)
Bulk rename operations
Smart folder creation and organization


Directory Analysis Tool

Analyze disk usage and file distribution
Find duplicate files
Identify large files and space usage patterns



Resources

File System Resources

Expose directory contents as subscribable resources
File content as readable resources
Real-time updates when files change



Prompts

File-based Prompts

Generate prompts based on project structure
Create file organization suggestions
Template prompts for common file operations



Technical Architecture
Framework Usage

Foundation: Core file system operations (FileManager, URL)
MCP Swift SDK: Server implementation and protocol handling
ServiceLifecycle: Graceful startup/shutdown management
Logging: Comprehensive logging for debugging

Key Components
Sources/MCPFileServer/
├── main.swift                 # Entry point with ServiceLifecycle
├── FileServer.swift          # Main MCP server setup and configuration
├── Tools/
│   ├── FileSearchTool.swift      # Implement file search functionality
│   ├── FileOrganizeTool.swift    # File organization and bulk operations  
│   └── DirectoryAnalysisTool.swift # Disk usage and analysis
├── Resources/
│   └── FileSystemResource.swift  # Directory and file content resources
└── Utils/
    ├── FileMetadata.swift     # File metadata extraction utilities
    └── PathUtils.swift       # Path manipulation helpers
Specific Implementation Requirements
MCP Server Setup

Use stdio transport for local subprocess communication
Implement proper capability declaration (tools, resources, prompts)
Include graceful shutdown with ServiceLifecycle
Add comprehensive logging throughout

File Search Tool
swift// Expected tool interface
{
  "name": "search_files",
  "description": "Search for files using various criteria",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {"type": "string", "description": "Search query (name/content)"},
      "path": {"type": "string", "description": "Root path to search"},
      "fileType": {"type": "string", "description": "Filter by file extension"},
      "maxResults": {"type": "integer", "default": 50},
      "includeContent": {"type": "boolean", "default": false}
    }
  }
}
File Organization Tool
swift// Expected tool interface  
{
  "name": "organize_files",
  "description": "Organize files in a directory",
  "inputSchema": {
    "type": "object", 
    "properties": {
      "sourcePath": {"type": "string", "description": "Directory to organize"},
      "strategy": {"type": "string", "enum": ["byType", "byDate", "bySize"]},
      "createSubfolders": {"type": "boolean", "default": true},
      "dryRun": {"type": "boolean", "default": true}
    }
  }
}
Directory Analysis Tool
swift// Expected tool interface
{
  "name": "analyze_directory", 
  "description": "Analyze directory structure and usage",
  "inputSchema": {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "Directory to analyze"},
      "includeSubdirs": {"type": "boolean", "default": true},
      "findDuplicates": {"type": "boolean", "default": false}
    }
  }
}
Error Handling & Safety

Validate all file paths to prevent directory traversal
Read-only operations by default unless explicitly requested
Dry-run mode for destructive operations
Proper error messages with context
Respect file permissions and handle access errors gracefully

Platform Integration

Use native macOS APIs where beneficial (Spotlight integration via CoreSpotlight)
Respect system permissions (don't require unnecessary privileges)
Follow macOS conventions for file organization
Optimize for SSD performance (common on modern Macs)

Development Priorities

Start simple: Basic file search with name-based queries
Add incrementally: Expand search capabilities, then add organization
Test thoroughly: Each tool should work independently
Focus on UX: Clear, helpful responses and error messages

Success Criteria

MCP client can successfully call all implemented tools
File operations are safe and respect user permissions
Results are accurate and properly formatted
Server handles errors gracefully without crashing
Performance is reasonable for typical directory sizes (< 1 second for most operations)