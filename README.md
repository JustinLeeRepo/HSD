# HSD

## Build And Run
Use any Xcode version 15.2+ to build and run proj


## 3rd Party Libs
None used

## AI Tools used
Gen AI was used only for the tests, 

`internal static func createCameraPositionWithRegion(waypoints: [Waypoint]) -> MapCameraPosition {` method,

and `String+Extensions.swift` class

The tests were reviewed and tweaked as necessary.

The createCameraPositionWithRegion was reviewed and sufficient to be left alone.

The String+Extensions class was reviewed but not understood. Left as is due to complexity.

## Architectural / Technical Decisions
I chose to use SwiftUI for a few reasons. 
I have been building in SwiftUI for the past 2 years and have not touched UIKit since.
But also, after my conversation with Leora and what the needs of this new hire was, I wanted to demonstrate my swiftUI abilities as it was highlighted this new hire should be someone with SwiftUI expereince that could help migrate the codebase away from UIKit and to SwiftUI.

I have a UIKit map based app published in the app store [PMail](http://apps.apple.com/us/app/pmail/id6466303913) (also leaving actual link instead of hyperlink) http://apps.apple.com/us/app/pmail/id6466303913 that was built without any 3rd party libraries (other than firebase). This app was built using Uber's RIBs architecture, instead of MVVM.

This codebase follows a MVVM pattern and can be seen from how the UI components are broken up into groups with their own dedicated view and viewModel at the very least. The components try to be as indepdent as possible without any dependencies / couplings to other components. The components are "coupled" together through pub/sub events via Combine. The event publishers are shared, but that is the extent of the depdencies on each other.

There is a service layer that has a concrete client, and then service abstractions that are mockable/stubbable and injectable for testing purposes.

There is some unneccessary components such as auth / auth sercurity in this project but were included to demonstrate a better picture of how a full functioning app would look.
