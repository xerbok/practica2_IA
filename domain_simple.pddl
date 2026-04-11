(define (domain magabot-simple)
  (:requirements :strips :typing)

  (:types
    robot cell shelf dispenser package
  )

  (:predicates
    ; Graella i moviment
    (adjacent ?from - cell ?to - cell)
    (robot-at ?r - robot ?c - cell)
    (free ?c - cell)

    ; Relacions de proximitat entre passadissos i elements no transitables
    (near-shelf ?c - cell ?s - shelf)
    (near-disp ?c - cell ?d - dispenser)

    ; Piles de paquets
    (on ?top - package ?below - package)
    (on-shelf ?p - package ?s - shelf)
    (on-robot ?p - package ?r - robot)
    (top-shelf ?s - shelf ?p - package)
    (top-robot ?r - robot ?p - package)
    (shelf-empty ?s - shelf)
    (robot-empty ?r - robot)

    ; Objectiu
    (required ?p - package)
    (dispensed ?p - package)
  )

  (:action move
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and
      (robot-at ?r ?from)
      (adjacent ?from ?to)
      (free ?to)
    )
    :effect (and
      (not (robot-at ?r ?from))
      (robot-at ?r ?to)
      (free ?from)
      (not (free ?to))
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
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on-shelf ?p ?s))
      (shelf-empty ?s)
      (not (robot-empty ?r))
      (on-robot ?p ?r)
      (top-robot ?r ?p)
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
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on-shelf ?p ?s))
      (shelf-empty ?s)
      (not (top-robot ?r ?q))
      (on ?p ?q)
      (top-robot ?r ?p)
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
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on ?p ?below))
      (top-shelf ?s ?below)
      (not (robot-empty ?r))
      (on-robot ?p ?r)
      (top-robot ?r ?p)
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
    )
    :effect (and
      (not (top-shelf ?s ?p))
      (not (on ?p ?below))
      (top-shelf ?s ?below)
      (not (top-robot ?r ?q))
      (on ?p ?q)
      (top-robot ?r ?p)
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
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on-robot ?p ?r))
      (robot-empty ?r)
      (not (shelf-empty ?s))
      (on-shelf ?p ?s)
      (top-shelf ?s ?p)
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
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on-robot ?p ?r))
      (robot-empty ?r)
      (not (top-shelf ?s ?q))
      (on ?p ?q)
      (top-shelf ?s ?p)
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
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on ?p ?below))
      (top-robot ?r ?below)
      (not (shelf-empty ?s))
      (on-shelf ?p ?s)
      (top-shelf ?s ?p)
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
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on ?p ?below))
      (top-robot ?r ?below)
      (not (top-shelf ?s ?q))
      (on ?p ?q)
      (top-shelf ?s ?p)
    )
  )

  ; --------- Dispensar al sortidor espacial ---------

  (:action dispense-single
    :parameters (?r - robot ?c - cell ?d - dispenser ?p - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-disp ?c ?d)
      (top-robot ?r ?p)
      (on-robot ?p ?r)
      (required ?p)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on-robot ?p ?r))
      (robot-empty ?r)
      (dispensed ?p)
    )
  )

  (:action dispense-stack
    :parameters (?r - robot ?c - cell ?d - dispenser ?p - package ?below - package)
    :precondition (and
      (robot-at ?r ?c)
      (near-disp ?c ?d)
      (top-robot ?r ?p)
      (on ?p ?below)
      (required ?p)
    )
    :effect (and
      (not (top-robot ?r ?p))
      (not (on ?p ?below))
      (top-robot ?r ?below)
      (dispensed ?p)
    )
  )
)