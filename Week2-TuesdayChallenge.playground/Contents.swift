//: Playground - noun: a place where people can play

import UIKit

//Code Challenge: Write a function that returns all the odd elements of an array

func oddElements(input: [String]) -> [String] {
  
  var oddArray = [String]()
  for (var i=0; i < input.count; i++) {
    if i%2 > 0 {
      oddArray.append(input[i])
    }
  }
  return oddArray
}

var returnedArray = [String]()
let inputArray = ["Zero", "One", "Two", "Three"]
let nextArray = ["zero"]
let thirdArray = ["zero", "one"]

returnedArray = oddElements(inputArray)
returnedArray = oddElements(nextArray)
returnedArray = oddElements(thirdArray)



