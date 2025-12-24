import gleam/int
import gleam/list
import gleam/string
import simplifile as file
import utils/argy

type PuzzleOperation {
  Addition
  Multiplication
}

type PuzzleInput {
  PuzzleInput(puzzle_lines: List(Int), operation: PuzzleOperation)
}

pub fn main() -> Nil {
  let args = argy.parse_args(root: "./src/day6/")
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let lines = string.split(contents, "\n")
  let puzzles = case args.part {
    2 -> process_lines_2(lines)
    _ -> process_lines(lines)
  }
  let result = solve(puzzles)
  echo result
  Nil
}

fn solve(puzzle_input: List(PuzzleInput)) -> Int {
  list.fold(puzzle_input, 0, fn(sum, puzzle) {
    let col_val =
      list.fold(
        puzzle.puzzle_lines,
        case puzzle.operation {
          Addition -> 0
          Multiplication -> 1
        },
        fn(math, p_line) {
          case puzzle.operation {
            Addition -> math + p_line
            Multiplication -> math * p_line
          }
        },
      )
    sum + col_val
  })
}

fn process_lines(lines: List(String)) -> List(PuzzleInput) {
  let num_num_lines = list.length(lines) - 1
  let #(parsed_vals, _) =
    list.fold(lines, #([], 0), fn(acc, line) {
      let #(value, curr_line) = acc
      let #(new_value, _) =
        list.fold(
          string.split(line, " "),
          #(value, 0),
          fn(col_acc: #(List(#(Int, PuzzleInput)), Int), col) {
            let #(col_list, col_count) = col_acc
            let col_val = case list.key_find(col_list, col_count) {
              Ok(found) -> found
              Error(_) -> PuzzleInput([], Addition)
            }
            case col {
              " " -> col_acc
              "" -> col_acc
              _ -> {
                case curr_line == num_num_lines {
                  True -> {
                    #(
                      list.key_set(
                        col_list,
                        col_count,
                        PuzzleInput(col_val.puzzle_lines, case col {
                          "*" -> Multiplication
                          _ -> Addition
                        }),
                      ),
                      col_count + 1,
                    )
                  }
                  False -> {
                    let assert Ok(number) = int.parse(col)
                    let new_lines = list.append(col_val.puzzle_lines, [number])
                    #(
                      list.key_set(
                        col_list,
                        col_count,
                        PuzzleInput(new_lines, col_val.operation),
                      ),
                      col_count + 1,
                    )
                  }
                }
              }
            }
          },
        )

      #(new_value, curr_line + 1)
    })
  list.map(parsed_vals, fn(line) {
    let #(_, puzzle) = line
    puzzle
  })
}

fn process_lines_2(lines: List(String)) -> List(PuzzleInput) {
  let num_num_lines = list.length(lines) - 1
  let #(parsed_vals, _) =
    list.fold(lines, #([], 0), fn(acc, line) {
      let #(value, curr_line) = acc
      let #(new_value, _count, _str, _poo) =
        list.fold(
          string.split(line, ""),
          #(value, 0, 0, True),
          fn(
            col_acc: #(
              List(#(Int, #(List(#(Int, String)), String))),
              Int,
              Int,
              Bool,
            ),
            char,
          ) {
            let #(col_list, col_count, char_count, last_is_space) = col_acc
            let col_val = case list.key_find(col_list, col_count) {
              Ok(found) -> found
              Error(_) -> #([], "+")
            }
            case char {
              " " -> #(
                col_list,
                case last_is_space {
                  True -> col_count
                  False -> col_count + 1
                },
                char_count + 1,
                True,
              )
              _ -> {
                let #(char_list, operator) = col_val
                case curr_line == num_num_lines {
                  True -> {
                    let new_col_list =
                      list.key_set(col_list, col_count, #(char_list, char))
                    #(new_col_list, col_count, char_count + 1, False)
                  }
                  False -> {
                    let char_val = case list.key_find(char_list, char_count) {
                      Ok(found) -> found
                      Error(_) -> ""
                    }
                    let new_char_list =
                      list.key_set(
                        char_list,
                        char_count,
                        string.append(char_val, char),
                      )
                    let new_col_list =
                      list.key_set(col_list, col_count, #(
                        new_char_list,
                        operator,
                      ))
                    #(new_col_list, col_count, char_count + 1, False)
                  }
                }
              }
            }
          },
        )
      #(new_value, curr_line + 1)
    })
  list.map(parsed_vals, fn(val) {
    let #(_index, puzzle_big) = val
    let #(stringy_puzzle, operator) = puzzle_big
    let puzzle_numbers =
      list.map(stringy_puzzle, fn(my_stuff) {
        let #(_index, num_string) = my_stuff
        let assert Ok(parsed_num) = int.parse(num_string)
        parsed_num
      })
    PuzzleInput(puzzle_lines: puzzle_numbers, operation: case operator {
      "*" -> Multiplication
      _ -> Addition
    })
  })
}
