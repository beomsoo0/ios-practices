import UIKit

let urlString = "https://www.google.com/search?q=configuration&oq=configuration&aqs=chrome.0.0i433j0i131i433j0j0i131i433j0l6.2653j0j4&sourceid=chrome&ie=UTF-8"
let url = URL(string: urlString)

url?.absoluteString
url?.scheme
url?.host
url?.path
url?.query
url?.baseURL

let baseURL = URL(string: "https://www.google.com")
let relativeURL = URL(string: "search?q=configuration&oq=configuration&aqs=chrome.0.0i433j0i131i433j0j0i131i433j0l6.2653j0j4&sourceid=chrome&ie=UTF-8", relativeTo: baseURL)

relativeURL?.absoluteString
relativeURL?.scheme
relativeURL?.host
relativeURL?.path
relativeURL?.query
relativeURL?.baseURL

// URLComponents

var urlComponents = URLComponents(string: "https://www.google.com/search?")
let qComponents = URLQueryItem(name: "q", value: "configuration")
let oqComponents = URLQueryItem(name: "oq", value: "configuration")
let aqsComponents = URLQueryItem(name: "aqs", value: "chrome.0.0i433j0i131i433j0j0i131i433j0l6.2653j0j4")
let sourceidComponents = URLQueryItem(name: "sourceid", value: "chrome&ie=UTF-8")

urlComponents?.queryItems?.append(qComponents)
urlComponents?.queryItems?.append(oqComponents)
urlComponents?.queryItems?.append(aqsComponents)
urlComponents?.queryItems?.append(sourceidComponents)

urlComponents?.url
urlComponents?.string
urlComponents?.queryItems
