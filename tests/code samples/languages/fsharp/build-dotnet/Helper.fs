namespace HelperNamespace

/// Make the module auto discoverable
[<AutoOpen>]
module HelperModule =

    let helloWorld salutation =
        printfn salutation

