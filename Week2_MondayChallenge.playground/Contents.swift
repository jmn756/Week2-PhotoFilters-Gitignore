//: Playground - noun: a place where people can play

import UIKit

//Code Challenge: Write a function that determines how many words there are in a sentence


func wordCount(sentence: String) ->Int {
  
  //var words: [String]
  var count = 0
  if !isEmpty(sentence) {
    let words = sentence.componentsSeparatedByString(" ")
    for word in words {
      if word != "" {
        count++
      }
    }
    //count = words.count
  }
  return count
}


var count: Int

count = wordCount("I am a sentence")
count = wordCount("")
count = wordCount("Yay")
count = wordCount("This sentence has 10 words to be counted, yes indeedy")
count = wordCount(" Adding a space in the front exposed a bug")  //Fixed!
count = wordCount("Space at the end ")
count = wordCount("Extra space  in the middle")

