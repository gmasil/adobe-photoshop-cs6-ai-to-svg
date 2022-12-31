# Adopbe Photoshop CS6 AI Path to SVG

This bash script can be used to create SVG files from Photoshop CS6 paths.

In Photoshop CS6 export a path using `File` -> `Export` -> `Path -> Illustrator...` and select all paths or the path you wan to export. Save the `*.ai` file. Then you can convert the Adobe Illustrator file to a generic SVG file with this script using

```bash
./convert-ai-to-svg.sh my-path-file.ai
```

The SVG file will bes aved as `my-path-file.ai.svg`.

A progress in percent can be enabled by setting the environment `VERBOSE` to `true`:

```bash
$ VERBOSE=true ./convert-ai-to-svg.sh my-path-file.ai
[INFO] 14.9%
[INFO] 28.8%
[INFO] 43.8%
[INFO] 59.1%
[INFO] 76.1%
[INFO] 92.0%
[INFO] Done
```
