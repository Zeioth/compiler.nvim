module Program

module Main =
    let run () =
        HelperNamespace.HelperModule.helloWorld "Hello World!"


// Use this only for compiled programs. Using it on REPL, will cause warnings.
[<EntryPoint>]
let main argv =
    Main.run ()
    0
