(define (domain magabot-advanced)
  (:requirements :strips :typing :numeric-fluents)

  (:types
    robot cell shelf dispenser charger package
  )

  (:predicates
    ; Graella i moviment
    (adjacent ?from - cell ?to - cell)
    (robot-at ?r - robot ?c - cell)
    (free ?c - cell)

    ; Relacions de proximitat amb elements no transitables
    (near-shelf ?c - cell ?s - shelf)
    (near-disp ?c - cell ?d - dispenser)
    (near-charger ?c - cell ?ch - charger)

    ; Piles de paquets
    (on ?top - package ?below - package)
    (on-shelf ?p - package ?s - shelf)
    (on-robot ?p - package ?r - robot)
    (top-shelf ?s - shelf ?p - package)
    (top-robot ?r - robot ?p - package)
    (shelf-empty ?s - shelf)
    (robot-empty ?r - robot)

    ; Objectiu i ordre
    (required ?p - package)
    (dispensed ?p - package)
    (current-required ?p - package)
    (next-required ?p - package ?q - package)
    (last-required ?p - package)

    ; Mode d'execució
    (unordered-mode)
    (ordered-mode)
  )

  (:functions
    (weight ?p - package)
    (load ?r - robot)
    (max-load ?r - robot)
    (energy ?r - robot)
    (max-energy ?r - robot)
    (total-cost)
  )

  ; Assumpció adoptada: amb 5 kg exactes el moviment costa 2 unitats.
  (:action move-light
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and
      (robot-at ?r ?from)
      (adjacent ?from ?to)
      (free ?to)
      (<= (load ?r) 5)
      (>= (energy ?r) 2)
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
      (free ?from)
      (not (free ?to))
      (decrease (energy ?r) 2)
      (increase (total-cost) 2)
    )
  )

  (:action move-heavy
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and
      (robot-at ?r ?from)
      (adjacent ?from ?to)
      (free ?to)
      (> (load ?r) 5)
      (>= (energy ?r) 3)
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
      (free ?from)
      (not (free ?to))
      (decrease (energy ?r) 3)
      (increase (total-cost) 3)
    )
  )

  ; --------- Agafar des d'una estanteria ---------

  (:action pickup-single-to-empty-robot
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-shelf ?s ?p)
      (on-shelf ?p ?s)
      (robot-empty ?r)
      (> (energy ?r) 0)
      (<= (+ (load ?r) (weight ?p)) (max-load ?r))
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on-shelf ?p ?s))
      (shelf-empty ?s)
      (not (robot-empty ?r))
      (on-robot ?p ?r)
      (top-robot ?r ?p)
      (increase (load ?r) (weight ?p))
    )
  )

  (:action pickup-single-to-stacked-robot
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package ?q - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-shelf ?s ?p)
      (on-shelf ?p ?s)
      (top-robot ?r ?q)
      (> (energy ?r) 0)
      (<= (+ (load ?r) (weight ?p)) (max-load ?r))
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on-shelf ?p ?s))
      (shelf-empty ?s)
      (not (top-robot ?r ?q))
      (on ?p ?q)
      (top-robot ?r ?p)
      (increase (load ?r) (weight ?p))
    )
  )

  (:action pickup-stack-to-empty-robot
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package ?below - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-shelf ?s ?p)
      (on ?p ?below)
      (robot-empty ?r)
      (> (energy ?r) 0)
      (<= (+ (load ?r) (weight ?p)) (max-load ?r))
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on ?p ?below))
      (top-shelf ?s ?below)
      (not (robot-empty ?r))
      (on-robot ?p ?r)
      (top-robot ?r ?p)
      (increase (load ?r) (weight ?p))
    )
  )

  (:action pickup-stack-to-stacked-robot
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package ?below - package ?q - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-shelf ?s ?p)
      (on ?p ?below)
      (top-robot ?r ?q)
      (> (energy ?r) 0)
      (<= (+ (load ?r) (weight ?p)) (max-load ?r))
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on ?p ?below))
      (top-shelf ?s ?below)
      (not (top-robot ?r ?q))
      (on ?p ?q)
      (top-robot ?r ?p)
      (increase (load ?r) (weight ?p))
    )
  )

  ; --------- Descarregar sobre una estanteria ---------

  (:action unload-single-to-empty-shelf
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-robot ?r ?p)
      (on-robot ?p ?r)
      (shelf-empty ?s)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on-robot ?p ?r))
      (robot-empty ?r)
      (not (shelf-empty ?s))
      (on-shelf ?p ?s)
      (top-shelf ?s ?p)
      (decrease (load ?r) (weight ?p))
    )
  )

  (:action unload-single-to-stacked-shelf
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package ?q - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-robot ?r ?p)
      (on-robot ?p ?r)
      (top-shelf ?s ?q)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on-robot ?p ?r))
      (robot-empty ?r)
      (not (top-shelf ?s ?q))
      (on ?p ?q)
      (top-shelf ?s ?p)
      (decrease (load ?r) (weight ?p))
    )
  )

  (:action unload-stack-to-empty-shelf
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package ?below - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-robot ?r ?p)
      (on ?p ?below)
      (shelf-empty ?s)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on ?p ?below))
      (top-robot ?r ?below)
      (not (shelf-empty ?s))
      (on-shelf ?p ?s)
      (top-shelf ?s ?p)
      (decrease (load ?r) (weight ?p))
    )
  )

  (:action unload-stack-to-stacked-shelf
    :parameters (?r - robot ?c - cell ?s - shelf ?p - package ?below - package ?q - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-shelf ?c ?s)
      (top-robot ?r ?p)
      (on ?p ?below)
      (top-shelf ?s ?q)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on ?p ?below))
      (top-robot ?r ?below)
      (not (top-shelf ?s ?q))
      (on ?p ?q)
      (top-shelf ?s ?p)
      (decrease (load ?r) (weight ?p))
    )
  )

  ; --------- Recarregar ---------

  (:action recharge-20
    :parameters (?r - robot ?c - cell ?ch - charger)
    :precondition (and
      (robot-at ?r ?c)
      (near-charger ?c ?ch)
      (> (energy ?r) 0)
      (<= (+ (energy ?r) 20) (max-energy ?r))
    )
    :effect (increase (energy ?r) 20)
  )

  (:action recharge-to-max
    :parameters (?r - robot ?c - cell ?ch - charger)
    :precondition (and
      (robot-at ?r ?c)
      (near-charger ?c ?ch)
      (> (energy ?r) 0)
      (> (+ (energy ?r) 20) (max-energy ?r))
    )
    :effect (assign (energy ?r) (max-energy ?r))
  )



; --------- Dispensació no ordenada ---------

(:action dispense-single-unordered
  :parameters (?r - robot ?c - cell ?d - dispenser ?p - package)
  :precondition (and
    (unordered-mode)
    (robot-at ?r ?c)
    (near-disp ?c ?d)
    (top-robot ?r ?p)
    (on-robot ?p ?r)
    (required ?p)
    (> (energy ?r) 0)
  )
  :effect (and
    (not (top-robot ?r ?p))
    (not (on-robot ?p ?r))
    (robot-empty ?r)
    (dispensed ?p)
    (decrease (load ?r) (weight ?p))
  )
)

(:action dispense-stack-unordered
  :parameters (?r - robot ?c - cell ?d - dispenser ?p - package ?below - package)
  :precondition (and
    (unordered-mode)
    (robot-at ?r ?c)
    (near-disp ?c ?d)
    (top-robot ?r ?p)
    (on ?p ?below)
    (required ?p)
    (> (energy ?r) 0)
  )
  :effect (and
    (not (top-robot ?r ?p))
    (not (on ?p ?below))
    (top-robot ?r ?below)
    (dispensed ?p)
    (decrease (load ?r) (weight ?p))
  )
)

  ; --------- Dispensació ordenada ---------

  (:action dispense-single-middle
    :parameters (?r - robot ?c - cell ?d - dispenser ?p - package ?next - package)
    :precondition (and
            (ordered-mode)
(robot-at ?r ?c)
      (near-disp ?c ?d)
      (top-robot ?r ?p)
      (on-robot ?p ?r)
      (required ?p)
      (current-required ?p)
      (next-required ?p ?next)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on-robot ?p ?r))
      (robot-empty ?r)
      (dispensed ?p)
      (not (current-required ?p))
      (current-required ?next)
      (decrease (load ?r) (weight ?p))
    )
  )

  (:action dispense-single-last
    :parameters (?r - robot ?c - cell ?d - dispenser ?p - package)
    :precondition (and
            (ordered-mode)
(robot-at ?r ?c)
      (near-disp ?c ?d)
      (top-robot ?r ?p)
      (on-robot ?p ?r)
      (required ?p)
      (current-required ?p)
      (last-required ?p)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on-robot ?p ?r))
      (robot-empty ?r)
      (dispensed ?p)
      (not (current-required ?p))
      (decrease (load ?r) (weight ?p))
    )
  )

  (:action dispense-stack-middle
    :parameters (?r - robot ?c - cell ?d - dispenser ?p - package ?below - package ?next - package)
    :precondition (and
            (ordered-mode)
(robot-at ?r ?c)
      (near-disp ?c ?d)
      (top-robot ?r ?p)
      (on ?p ?below)
      (required ?p)
      (current-required ?p)
      (next-required ?p ?next)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on ?p ?below))
      (top-robot ?r ?below)
      (dispensed ?p)
      (not (current-required ?p))
      (current-required ?next)
      (decrease (load ?r) (weight ?p))
    )
  )

  (:action dispense-stack-last
    :parameters (?r - robot ?c - cell ?d - dispenser ?p - package ?below - package)
    :precondition (and
            (ordered-mode)
(robot-at ?r ?c)
      (near-disp ?c ?d)
      (top-robot ?r ?p)
      (on ?p ?below)
      (required ?p)
      (current-required ?p)
      (last-required ?p)
      (> (energy ?r) 0)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on ?p ?below))
      (top-robot ?r ?below)
      (dispensed ?p)
      (not (current-required ?p))
      (decrease (load ?r) (weight ?p))
    )
  )
)