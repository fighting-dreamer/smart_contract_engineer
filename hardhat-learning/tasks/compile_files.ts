import { task, subtask } from "hardhat/config";
import {
  TASK_COMPILE,
  TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS,
} from "hardhat/builtin-tasks/task-names";
import path from "path";

// A global variable to store the files to be compiled
let specificFilesToCompile: string[] = [];

/**
 * Custom task to compile a specific set of contract files.
 *
 * Usage:
 * npx hardhat compile:files [--force] <file1.sol> <file2.sol> ...
 */
task("compile:files", "Compiles a specific list of files")
  .addVariadicPositionalParam("files", "The files to compile")
  .addFlag("force", "Force compilation ignoring cache")
  .setAction(async (taskArgs, hre) => {
    // Store absolute paths of files to compile
    specificFilesToCompile = taskArgs.files.map((file: string) =>
      path.resolve(process.cwd(), file)
    );

    // Run the main compile task with the same flags
    await hre.run(TASK_COMPILE, {
      force: taskArgs.force,
      quiet: false,
    });

    // Reset the global variable after compilation
    specificFilesToCompile = [];
  });

/**
 * Override the subtask that gets the list of source files.
 * If our custom task is running, we return our specific list of files.
 * Otherwise, we fall back to the default behavior.
 */
subtask(TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS).setAction(
  async (_, __, runSuper) => {
    if (specificFilesToCompile.length > 0) {
      return specificFilesToCompile;
    }
    return runSuper();
  }
);
