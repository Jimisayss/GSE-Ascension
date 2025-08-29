# GSE for Ascension (3.3.5)

This is a modified version of Gnome Sequencer Enhanced (GSE) adapted for the Ascension private server environment (WoW client 3.3.5).

## Installation

1.  Download the addon from [repository link].
2.  Extract the `GSE` and `GSE_GUI` folders into your `Interface\AddOns` directory.
3.  Restart your WoW client.

## Key Features for Ascension

*   **Classless Support:** Create and use sequences with spells from any class.
*   **Modern UX:** The modern GSE user interface for creating and managing sequences is preserved.
*   **Reliable Step Functions:** Sequential, Random, and a deterministic Priority mode are supported.

## How to Use

### Setting the Step Function

When creating or editing a sequence, you can specify the `StepFunction` to control the order in which actions are executed.

*   **Sequential:** `1, 2, 3, 1, 2, 3, ...`
*   **Random:** A random action is chosen on each click.
*   **Priority:** `1, 1, 2, 1, 2, 3, 1, 2, 3, 4, ...`

You can set this in the sequence's configuration within the GSE editor.

### Single Macro Scope

This version of GSE creates all macro stubs in your **account-wide (General)** macro list. There is no option to use character-specific macros. This is done to prevent macro duplication and ensure sequences are available to all your characters.

### Debugging

A new debug option has been added for this version. To enable it, open the GSE options (`/gs`) and check the `AscensionDebug` box. This will print detailed information about the priority step function to your chat window.
