let 
    is_even = func (n) { if n == 0 then true  else is_odd( n - 1 )  },
    is_odd  = func (n) { if n == 0 then false else is_even( n - 1 ) },
 in
    is_even( 2 )
;;