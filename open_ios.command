#!/bin/bash
# Opens the iOS project in Xcode using the workspace (required for CocoaPods)
# Double-click this file or run: ./open_ios.command
cd "$(dirname "$0")"
open ios/Runner.xcworkspace
