# Adopbe Photoshop CS6 AI Path to SVG

This bash script can be used to create SVG files from Photoshop CS6 paths.

In Photoshop CS6 export a path using `File` -> `Export` -> `Path -> Illustrator...` and select all paths or the path you wan to export. Save the `*.ai` file. Then you can convert the Adobe Illustrator file to a generic SVG file with this script using

```bash
./convert-ai-to-svg.sh my-path-file.ai
```
