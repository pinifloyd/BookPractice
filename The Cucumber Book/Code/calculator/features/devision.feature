Feature: Devision

  Scenario Outline: Devide two numbers
    Given the input "<input>"
    When the calculator is run
    Then the output should be "<output>"
    
    Examples:
      | input | output |
      | 2-2   | 0      |
      | 37-6  | 31     |