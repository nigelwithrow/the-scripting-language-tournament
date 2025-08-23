/*
  # The Scripting Language Tournament by InfiniteCoder01
  Challenge 3 - Lost in files
  Date: 23rd August 2025

  Entry:  Typescript
  Author: Nigel Withrow <nigelwithrow78@gmail.com>

  Instructions:
  + `$ cd 3-lost-in-files`
  + `$ yarn install`
  + `$ yarn tsc`
  + `$ node main.js /path/to/archive.tar.gz`
*/

import * as tar from "tar";
import fs from "node:fs";
import { Readable } from "node:stream";
import { argv } from "node:process";

function readEntries(archive: Readable) {
  const read = archive
    .pipe(
      tar.extract({
        // Don't crash on warnings/errors
        strict: false,
        // Callback on each entry
        transform(entry) {
          // Collect & concatenate entry stream into buffer
          entry.concat()
            .then((buf) => {
              // Recurse over this entry to once again uncompress & unarchive it
              readEntries(Readable.from(buf))
                .on("error", (e) =>
                  // TAR_BAD_ARCHIVE errors mean the entry was not an archive, i.e., it was text
                  (e.code === "TAR_BAD_ARCHIVE") &&
                  buf.toString()
                    // Split contents by line
                    .split("\n")
                    .forEach((line) => {
                      // If line has answer, print it
                      if (/^Answer:.*$/.test(line)) {
                        console.log(line);
                      }
                    })
                );
            });
        },
      })
    );
  return read;
}

type Input = { filename: string; };

function solve(input: Input) {
  // Start reading entries from the provided archive filename
  readEntries(fs.createReadStream(input.filename));
}

// Get archive filename from CLI arguments
if (argv.length < 3 || !argv[2]) // ["node", "main.js", "file.tar.gz"]
  console.error("Expecting argument for filename of compressed archive .tar.gz");
else
  solve({ filename: argv[2] });
