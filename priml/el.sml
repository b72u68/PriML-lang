
(* The External Language *)

structure EL =
struct

  type intconst = Word32.word
  type priority = string
  type prio = string
  type pconstraint = prio * prio
(*
      PrVar of string
    | PrConst of priority
*)

  datatype exp_ =

      Constant of constant
    | Var of string
    | Float of real

    | App of exp * exp * bool (* infix? *)

    | Let of dec * exp

    | Record of (string * exp) list
    (* vector constructor *)
    | Vector of exp list
    (* #label/typ exp *)
    | Proj of string * typ * exp

    | Andalso of exp * exp
    | Orelse of exp * exp
    | Andthen of exp * exp
    | Otherwise of exp * exp
    | If of exp * exp * exp

    | Primapp of string * typ list * exp list

    | Seq of exp * exp
    | Constrain of exp * typ

    (* same as concat, maybe worth making efficient *)
    (* | Jointext of exp list *)

    | Raise of exp

    (* optional delayed default can only be generated by the compiler *)
    | Case of exp list * (pat list * exp) list * (unit -> exp) option

    (* compile-time warning if this code is live *)
    | CompileWarn of string

    | ECmd of prio * cmd
    | PFn of ppat list * pat list * exp
    | PApply of exp * prio

    | Handle of exp * (pat * exp) list

  and inst_ =
      IDo of exp
    | Spawn of prio * cmd
    | Change of prio
    | Sync of exp
    | Poll of exp
    | Cancel of exp
    | IRet of exp

  and cmd =
      Cmd of ((string * inst) list) * inst

  and constant =
      CInt of intconst
    | CString of string
    | CChar of char

  and pat =
      PVar of string
    | PWild
    | PAs of string * pat
    | PRecord of (string * pat) list
    | PConstrain of pat * typ
    | PConstant of constant
    | PApp of string * pat option
    | PWhen of exp * pat

(*  and pconstraint =
      CLess of prio * prio
    | CAnd of pconstraint * pconstraint
 *)

  and ppat =
      PPVar of string
    | PPConstrain of string * pconstraint list (* pconstraint *)

  and typ =
      TVar of string
    | TApp of typ list * string
    | TRec of (string * typ) list
(*    | TSham of string option * typ
    | TAt of typ * world *)
    | TArrow of typ * typ
    (* shortcut for tuple length *)
    | TNum of int
  (*     | TAddr of world (* can only be the address of a world expression *) *)
    | TCmd of typ * prio
    | TThread of typ * prio list
    | TForall of ppat * typ

  and dec_ =
      (* wish we had refinements here.
         val pat cannot contain PConstant or PApp *)
      (* val (a, b) loop = Util.loop : a -> b *)
      Val of string list * pat * exp
    | Do of exp
    | Type of string list * string * typ

    (* fun (a, b, c) f p1 p2 p3 : t1 = e1
         |           f p1 p2 p3 : t2 = e2
       and g p1 p2 : t3 = e3
         | ... *)
    | Fun of { inline : bool,
               funs : (string list * string *
                       (pat list * typ option * exp) list) list }

    | WFun of string * ppat list * pat list * typ option * exp

    (* datatype (a, b, c) t = A of t | B of b | C of t1
       and                u = D of u | E of t *)
    | Datatype of string list *
                  (string * (string * typ option) list) list
    | Tagtype of string
      (* newtag Fail (valid?) of string in exn *)
    | Newtag of string * typ option * string
      (* just means newtag E of TO in "exn" *)
    | Exception of string * typ option

    (* extern val (a, b) loop : a -> b  @ w
       or
       extern val (a, b) loop ~ a -> b
       or
       extern val (a, b) loop ~ w => (a -> b) at w
       or
       extern val (a, b) loop : a -> b  @ w  =  real_label_of_loop
     *)

  and tdec =
      Dec of dec
    | Priority of string
    | Order of string * string
    | Fairness of string * intconst

  and prog =
      Prog of tdec list * cmd
  (* fixity decls are handled at parse time *)

(*
  and elunit =
    Unit of dec list * export list

  and export =
    (* in the case that the export is not supplied,
       we assume the identifier also used for export *)
    ExportType of string list * string * typ option
  | ExportVal of string list * string * exp option

*)

  withtype exp = exp_ * Pos.pos
  and dec = dec_ * Pos.pos
  and inst = inst_ * Pos.pos

end
