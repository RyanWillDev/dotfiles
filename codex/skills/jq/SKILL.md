---
name: jq
description: Use when the user needs to parse, query, transform, validate, or reformat JSON. Covers extracting fields, filtering arrays, reshaping JSON structures, pretty-printing output, and processing JSON from files, stdin, or command output with `jq`.
---

# jq - Command-line JSON Processor

You are an expert at using `jq` to work with JSON data in the command line.

## Your Capabilities

When this skill is active, help users with:

1. **Parsing and pretty-printing JSON**
   - Format JSON output for readability
   - Validate JSON syntax

2. **Querying and filtering**
   - Extract specific fields or values
   - Filter arrays based on conditions
   - Navigate nested JSON structures

3. **Transforming JSON**
   - Modify field values
   - Reshape JSON structure
   - Combine or split JSON objects

4. **Array operations**
   - Map, filter, and reduce operations
   - Sort and group data
   - Flatten or nest arrays

5. **Working with multiple JSON files**
   - Merge JSON data
   - Compare JSON structures

## Common jq Patterns

### Basic Operations
```bash
# Pretty-print JSON
jq '.' file.json

# Extract a field
jq '.fieldName' file.json

# Extract nested field
jq '.parent.child' file.json

# Get array element
jq '.[0]' file.json
jq '.items[2]' file.json
```

### Array Operations
```bash
# Get all elements from array
jq '.[]' file.json

# Map over array
jq '.items[] | .name' file.json

# Filter array
jq '.items[] | select(.price > 10)' file.json

# Get array length
jq '.items | length' file.json

# Sort array
jq '.items | sort_by(.price)' file.json
```

### Transforming Data
```bash
# Create new object
jq '{name: .name, total: .price}' file.json

# Rename field
jq '{newName: .oldName, other: .other}' file.json

# Add field
jq '. + {newField: "value"}' file.json

# Delete field
jq 'del(.fieldName)' file.json
```

### Advanced Filtering
```bash
# Multiple conditions
jq '.items[] | select(.price > 10 and .inStock == true)' file.json

# Check if field exists
jq 'select(.fieldName != null)' file.json

# Regex matching
jq '.items[] | select(.name | test("pattern"))' file.json
```

### Aggregations
```bash
# Sum values
jq '[.items[].price] | add' file.json

# Get unique values
jq '[.items[].category] | unique' file.json

# Group by field
jq 'group_by(.category)' file.json
```

### Working with Multiple Files
```bash
# Combine JSON files
jq -s '.' file1.json file2.json

# Merge objects
jq -s 'add' file1.json file2.json
```

### Output Formats
```bash
# Compact output (no pretty-print)
jq -c '.' file.json

# Raw output (no quotes for strings)
jq -r '.fieldName' file.json

# Tab-separated values
jq -r '.items[] | [.name, .price] | @tsv' file.json

# CSV output
jq -r '.items[] | [.name, .price] | @csv' file.json
```

## Usage Guidelines

1. **Always use single quotes** around jq filters to prevent shell interpretation
2. **Use `-r` flag** for raw output when you want unquoted strings
3. **Use `-c` flag** for compact JSON (single line)
4. **Use `-s` flag** (slurp) to read entire input as single array
5. **Pipe from stdin** when working with command output: `curl api.example.com | jq '.data'`
6. **Handle errors gracefully** with try-catch: `jq 'try .field catch "default"'`

## Common Use Cases

### API Response Processing
```bash
# Extract specific fields from API response
curl -s https://api.example.com/users | jq '.users[] | {id, name, email}'
```

### Configuration File Management
```bash
# Update config value
jq '.config.timeout = 30' config.json > config.json.tmp && mv config.json.tmp config.json
```

### Log Analysis
```bash
# Filter and format log entries
jq 'select(.level == "error") | {time, message}' logs.json
```

### Data Transformation for Other Tools
```bash
# Convert JSON to CSV
jq -r '.[] | [.name, .email, .age] | @csv' data.json > output.csv
```

## Tips

- Use `jq --help` to see all available options
- Test complex queries on small samples first
- Use `jq -C` to force colored output even when piping
- Combine with other Unix tools: `jq ... | grep ... | sort`
- For very large files, consider using `jq -c` to process line-by-line

## When to Use This Skill

Activate this skill whenever the user:
- Mentions JSON, jq, or JSON processing
- Needs to parse, query, or transform JSON data
- Wants to extract information from JSON files or API responses
- Needs to reformat or validate JSON
- Wants to filter, sort, or manipulate JSON arrays
- Needs to convert JSON to other formats (CSV, TSV, etc.)
