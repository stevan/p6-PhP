
let mul = func (x, y) { 
    if y == 1 
        then x
        else x + mul( x, y - 1 )
} in
    mul(13, 2)
;;