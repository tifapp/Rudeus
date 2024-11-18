# Rudeus Server

The server for powering the Rudeus engine used to create the journey feature in tiF.

## Overview

Rudeus is the engine that powers the journey in tiF, and internally an editor is used to create cutscenes for the journey. This editor runs as a mobile app to ensure that cutscenes are created in the same environment that they will run on in production.

For instance, this allows advanced haptic patterns to be created with ease. The iteration loop on developing the haptic pattern is nearly instant because the pattern is created directly on the hardware it will run on. If the editor were to run as a separate application on a desktop, this iteration would be impossible.

However, there is 1 primary problem with using a mobile app as the editor, and that is the share ability. The editor needs to generate code based on what is created from it, but it’s hard to get that code off a mobile device and into the actual tiF codebase. Additionally, it’s also hard to share cutscenes or haptic patterns with teammates in such an environment. Therefore, this server exists to enable that sharing.

For instance, when a new haptic pattern is created, its AHAP data gets stored in a centralized database. The code for the pattern is then sent to a slack channel where it can be easily copied and pasted into the tiF codebase.

## Development

This server uses Swift’s [Hummingbird](https://github.com/hummingbird-project/hummingbird)<!-- {"preview":"true"} --> framework which is a lightweight alternative to Vapor in the Swift world. The main reason for choosing Hummingbird was due to its unopinionated architecture compared to Vapor, which likes to impose a specific project structure, and also because the original developer wanted to try out the framework.

Authentication is handled through simple JWTs. Users do not create passwords when registering because accounts are only meant to be tied to 1 device, that device uses the JWT returned from the `api/register` endpoint. Since only 1 device per account is needed, there is no reason that a user would need to enter their password to login to their account from another device.

SQLite is used as the database due to the simple nature of this application, and it is used in the `RudeusDatabase` actor. When adding new migrations, please ensure to add a new `migrateVX` function. This makes it clear what iteration the migration changes come in.
