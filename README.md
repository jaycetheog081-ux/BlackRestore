# BlackRestore

BlackRestore is an iOS recovery and restoration research project.

The long-term goal is to investigate whether a stock iPhone can act as
a wired host for recovery and restoration operations on another iPhone,
iPad, or iPod touch.

## Current version

Version: 0.1.0

Status: USB feasibility prototype.

## Features

- Native Objective-C application.
- External Accessory framework integration.
- Supported accessory connection notifications.
- Accessory inventory reporting.
- Diagnostic logging.
- Recovery research information.
- Firmware research information.

## Important limitations

The current prototype does not implement firmware restoration.

The External Accessory framework is not a general-purpose USB interface
for arbitrary iPhones, iPads, or iPod touch devices. An accessory scan
does not establish that a target device can be accessed in Recovery
Mode or DFU mode.

Direct restoration from a jailed iPhone remains a research objective,
not a demonstrated capability.

## Requirements

- Xcode and iOS SDK.
- XcodeGen.
- Objective-C support.
- GitHub Actions for automated builds.

## Build

Generate the Xcode project:

    xcodegen generate --spec project.yml

Build the application:

    xcodebuild \
      -project BlackRestore.xcodeproj \
      -scheme BlackRestore \
      -configuration Release \
      -sdk iphoneos \
      -derivedDataPath build/DerivedData \
      CODE_SIGNING_ALLOWED=NO \
      build

GitHub Actions packages the unsigned application as BlackRestore.ipa.

## Installation

The workflow produces an unsigned IPA. It is not ready for direct
installation until an appropriate signing and installation method
has been applied.

## Roadmap

1. Establish USB communication feasibility.
2. Investigate target-device identification.
3. Research Recovery Mode and DFU communication.
4. Develop a technically viable restoration engine.
5. Evaluate device and firmware compatibility.
