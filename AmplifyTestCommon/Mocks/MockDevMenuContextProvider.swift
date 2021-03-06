//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

/// Mock class for presenting UI context to developer menu
class MockDevMenuContextProvider: DevMenuPresentationContextProvider {

    let uiWindow = UIWindow()

    func devMenuPresentationContext() -> UIWindow {
        return uiWindow
    }
}
