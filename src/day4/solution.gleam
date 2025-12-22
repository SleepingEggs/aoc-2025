import gleam/list
import gleam/string
import simplifile as file
import utils/argy

pub fn main() -> Nil {
  let args = argy.parse_args(root: "./src/day3/")
  let path = args.input_file
  let assert Ok(contents) = file.read(from: path)
  let lines = string.split(contents, "\n")
  let grid = generate_grid(lines)
  let result = solve(grid)
  echo result
  Nil
}

fn generate_grid(lines: List(String)) -> List(List(Int)) {
  list.map(lines, fn(line) {
    let split_line = string.split(line, "")
    list.map(split_line, fn(new_line) {
      case new_line {
        "@" -> 1
        _ -> 0
      }
    })
  })
}

fn solve(grid: List(List(Int))) -> Int {
  let indexed_grid =
    list.index_map(grid, fn(inner_list, index) {
      let indexed_list =
        list.index_map(inner_list, fn(val, ind) { #(ind, val) })
      #(index, indexed_list)
    })
  list.fold(indexed_grid, 0, fn(acc, item) {
    let #(y_index, row) = item
    acc
    + list.fold(row, 0, fn(x_acc, x_item) {
      let #(x_index, paper) = x_item
      case paper {
        1 -> x_acc + apply_mask_part_1(indexed_grid, #(x_index, y_index))
        _ -> x_acc
      }
    })
  })
}

fn apply_mask_part_1(
  indexed_grid: List(#(Int, List(#(Int, Int)))),
  coord: #(Int, Int),
) -> Int {
  let #(x, y) = coord
  let mask_coords = [
    #(x - 1, y - 1),
    #(x, y - 1),
    #(x + 1, y - 1),
    #(x - 1, y),
    #(x + 1, y),
    #(x - 1, y + 1),
    #(x, y + 1),
    #(x + 1, y + 1),
  ]
  let mask_result =
    list.fold(mask_coords, 0, fn(acc, i) {
      let #(mask_x, mask_y) = i
      let y_result = list.key_find(indexed_grid, mask_y)
      case y_result {
        Ok(ok_result) -> {
          let x_result = list.key_find(ok_result, mask_x)
          case x_result {
            Ok(x_ok_result) -> acc + x_ok_result
            Error(_err) -> acc
          }
        }
        Error(_err) -> acc
      }
    })
  case mask_result < 4 {
    True -> 1
    False -> 0
  }
}
