//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import PersonalityInsightsV3

let username = "5bc889c8-28ab-47f1-b884-24067647ad71"
let password = "rUTT5aRAujwX"
let version = "2018-01-28" // use today's date for the most recent version
let personalityInsights = PersonalityInsights(username: username, password: password, version: version)

let text = "hello hi"
let failure = { (error: Error) in print(error) }
personalityInsights.getProfile(fromText: text, failure: failure) { profile in
    print(profile)
}
