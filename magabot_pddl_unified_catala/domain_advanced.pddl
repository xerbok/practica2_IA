(define (domain magabot-advanced)
  (:requirements :strips :typing :numeric-fluents)

  (:types
    robot casella prestatgeria dispensador carregador paquet
  )

  (:predicates
    ; Graella i moviment
    (adjacent ?origen - casella ?desti - casella)
    (robot-at ?rob - robot ?cas - casella)
    (lliure ?cas - casella)

    ; Relacions de proximitat amb elements no transitables
    (prop-prestatgeria ?cas - casella ?pre - prestatgeria)
    (prop-dispensador ?cas - casella ?disp - dispensador)
    (prop-carregador ?cas - casella ?car - carregador)

    ; Piles de paquets
    (on ?damunt - paquet ?sota - paquet)
    (on-prestatgeria ?paq - paquet ?pre - prestatgeria)
    (on-robot ?paq - paquet ?rob - robot)
    (top-prestatgeria ?pre - prestatgeria ?paq - paquet)
    (top-robot ?rob - robot ?paq - paquet)
    (prestatgeria-buida ?pre - prestatgeria)
    (robot-buit ?rob - robot)

    ; Objectiu i ordre
    (requerit ?paq - paquet)
    (dispensat ?paq - paquet)
    (requerit-actual ?paq - paquet)
    (seguent-requerit ?paq - paquet ?paq2 - paquet)
    (ultim-requerit ?paq - paquet)

    ; Mode d'execució -> avançat1a fa servir no ordenat i avançat1b+avançat2b fan servir ordenat
    (mode-no-ordenat)
    (mode-ordenat)
  )

  (:functions
    (pes ?paq - paquet)
    (carrega ?rob - robot)
    (max-carrega ?rob - robot)
    (energia ?rob - robot)
    (max-energia ?rob - robot)
    (cost-total)
  )

  ; Si el pes total es de 5 kg justos, continua fent servir mou-lleuger

  (:action mou-lleuger
    :parameters (?rob - robot ?origen - casella ?desti - casella)
    :precondition (and
      (robot-at ?rob ?origen)
      (adjacent ?origen ?desti)
      (lliure ?desti)
      (<= (carrega ?rob) 5)
      (>= (energia ?rob) 2)
    )
    :effect (and
      (not (robot-at ?rob ?origen))
      (robot-at ?rob ?desti)
      (lliure ?origen)
      (not (lliure ?desti))
      (decrease (energia ?rob) 2)
      (increase (cost-total) 2)
    )
  )

  (:action mou-carregat
    :parameters (?rob - robot ?origen - casella ?desti - casella)
    :precondition (and
      (robot-at ?rob ?origen)
      (adjacent ?origen ?desti)
      (lliure ?desti)
      (> (carrega ?rob) 5)
      (>= (energia ?rob) 3)
    )
    :effect (and
      (not (robot-at ?rob ?origen))
      (robot-at ?rob ?desti)
      (lliure ?origen)
      (not (lliure ?desti))
      (decrease (energia ?rob) 3)
      (increase (cost-total) 3)
    )
  )

  ; Agafar des d'una estanteria

  (:action agafa-unitari-a-robot-buit
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-prestatgeria ?pre ?paq)
      (on-prestatgeria ?paq ?pre)
      (robot-buit ?rob)
      (> (energia ?rob) 0)
      (<= (+ (carrega ?rob) (pes ?paq)) (max-carrega ?rob))
    )
    :effect (and
      (not (top-prestatgeria ?pre ?paq))
      (not (on-prestatgeria ?paq ?pre))
      (prestatgeria-buida ?pre)
      (not (robot-buit ?rob))
      (on-robot ?paq ?rob)
      (top-robot ?rob ?paq)
      (increase (carrega ?rob) (pes ?paq))
    )
  )

  (:action agafa-unitari-a-robot-ple
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet ?paq2 - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-prestatgeria ?pre ?paq)
      (on-prestatgeria ?paq ?pre)
      (top-robot ?rob ?paq2)
      (> (energia ?rob) 0)
      (<= (+ (carrega ?rob) (pes ?paq)) (max-carrega ?rob))
    )
    :effect (and
      (not (top-prestatgeria ?pre ?paq))
      (not (on-prestatgeria ?paq ?pre))
      (prestatgeria-buida ?pre)
      (not (top-robot ?rob ?paq2))
      (on ?paq ?paq2)
      (top-robot ?rob ?paq)
      (increase (carrega ?rob) (pes ?paq))
    )
  )

  (:action agafa-pila-a-robot-buit
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet ?sota - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-prestatgeria ?pre ?paq)
      (on ?paq ?sota)
      (robot-buit ?rob)
      (> (energia ?rob) 0)
      (<= (+ (carrega ?rob) (pes ?paq)) (max-carrega ?rob))
    )
    :effect (and
      (not (top-prestatgeria ?pre ?paq))
      (not (on ?paq ?sota))
      (top-prestatgeria ?pre ?sota)
      (not (robot-buit ?rob))
      (on-robot ?paq ?rob)
      (top-robot ?rob ?paq)
      (increase (carrega ?rob) (pes ?paq))
    )
  )

  (:action agafa-pila-a-robot-ple
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet ?sota - paquet ?paq2 - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-prestatgeria ?pre ?paq)
      (on ?paq ?sota)
      (top-robot ?rob ?paq2)
      (> (energia ?rob) 0)
      (<= (+ (carrega ?rob) (pes ?paq)) (max-carrega ?rob))
    )
    :effect (and
      (not (top-prestatgeria ?pre ?paq))
      (not (on ?paq ?sota))
      (top-prestatgeria ?pre ?sota)
      (not (top-robot ?rob ?paq2))
      (on ?paq ?paq2)
      (top-robot ?rob ?paq)
      (increase (carrega ?rob) (pes ?paq))
    )
  )

  ; Descarregar sobre una estanteria

  (:action descarrega-unitari-a-prestatgeria-buida
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-robot ?rob ?paq)
      (on-robot ?paq ?rob)
      (prestatgeria-buida ?pre)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on-robot ?paq ?rob))
      (robot-buit ?rob)
      (not (prestatgeria-buida ?pre))
      (on-prestatgeria ?paq ?pre)
      (top-prestatgeria ?pre ?paq)
      (decrease (carrega ?rob) (pes ?paq))
    )
  )

  (:action descarrega-unitari-a-prestatgeria-ocupada
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet ?paq2 - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-robot ?rob ?paq)
      (on-robot ?paq ?rob)
      (top-prestatgeria ?pre ?paq2)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on-robot ?paq ?rob))
      (robot-buit ?rob)
      (not (top-prestatgeria ?pre ?paq2))
      (on ?paq ?paq2)
      (top-prestatgeria ?pre ?paq)
      (decrease (carrega ?rob) (pes ?paq))
    )
  )

  (:action descarrega-pila-a-prestatgeria-buida
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet ?sota - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-robot ?rob ?paq)
      (on ?paq ?sota)
      (prestatgeria-buida ?pre)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on ?paq ?sota))
      (top-robot ?rob ?sota)
      (not (prestatgeria-buida ?pre))
      (on-prestatgeria ?paq ?pre)
      (top-prestatgeria ?pre ?paq)
      (decrease (carrega ?rob) (pes ?paq))
    )
  )

  (:action descarrega-pila-a-prestatgeria-ocupada
    :parameters (?rob - robot ?cas - casella ?pre - prestatgeria ?paq - paquet ?sota - paquet ?paq2 - paquet)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-prestatgeria ?cas ?pre)
      (top-robot ?rob ?paq)
      (on ?paq ?sota)
      (top-prestatgeria ?pre ?paq2)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on ?paq ?sota))
      (top-robot ?rob ?sota)
      (not (top-prestatgeria ?pre ?paq2))
      (on ?paq ?paq2)
      (top-prestatgeria ?pre ?paq)
      (decrease (carrega ?rob) (pes ?paq))
    )
  )

  ; Recarregar energia

  (:action recarrega-20
    :parameters (?rob - robot ?cas - casella ?car - carregador)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-carregador ?cas ?car)
      (> (energia ?rob) 0)
      (<= (+ (energia ?rob) 20) (max-energia ?rob))
    )
    :effect (increase (energia ?rob) 20)
  )

  (:action recarrega-fins-max
    :parameters (?rob - robot ?cas - casella ?car - carregador)
    :precondition (and
      (robot-at ?rob ?cas)
      (prop-carregador ?cas ?car)
      (> (energia ?rob) 0)
      (> (+ (energia ?rob) 20) (max-energia ?rob))
    )
    :effect (assign (energia ?rob) (max-energia ?rob))
  )



; Dispensar paquet de manera no ordenada

(:action dispensa-unitari-no-ordenat
  :parameters (?rob - robot ?cas - casella ?disp - dispensador ?paq - paquet)
  :precondition (and
    (mode-no-ordenat)
    (robot-at ?rob ?cas)
    (prop-dispensador ?cas ?disp)
    (top-robot ?rob ?paq)
    (on-robot ?paq ?rob)
    (requerit ?paq)
    (> (energia ?rob) 0)
  )
  :effect (and
    (not (top-robot ?rob ?paq))
    (not (on-robot ?paq ?rob))
    (robot-buit ?rob)
    (dispensat ?paq)
    (decrease (carrega ?rob) (pes ?paq))
  )
)

(:action dispensa-pila-no-ordenat
  :parameters (?rob - robot ?cas - casella ?disp - dispensador ?paq - paquet ?sota - paquet)
  :precondition (and
    (mode-no-ordenat)
    (robot-at ?rob ?cas)
    (prop-dispensador ?cas ?disp)
    (top-robot ?rob ?paq)
    (on ?paq ?sota)
    (requerit ?paq)
    (> (energia ?rob) 0)
  )
  :effect (and
    (not (top-robot ?rob ?paq))
    (not (on ?paq ?sota))
    (top-robot ?rob ?sota)
    (dispensat ?paq)
    (decrease (carrega ?rob) (pes ?paq))
  )
)

  ; Dispensar paquet de forma ordenada

  (:action dispensa-unitari-mig
    :parameters (?rob - robot ?cas - casella ?disp - dispensador ?paq - paquet ?seguent - paquet)
    :precondition (and
      (mode-ordenat)
      (robot-at ?rob ?cas)
      (prop-dispensador ?cas ?disp)
      (top-robot ?rob ?paq)
      (on-robot ?paq ?rob)
      (requerit ?paq)
      (requerit-actual ?paq)
      (seguent-requerit ?paq ?seguent)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on-robot ?paq ?rob))
      (robot-buit ?rob)
      (dispensat ?paq)
      (not (requerit-actual ?paq))
      (requerit-actual ?seguent)
      (decrease (carrega ?rob) (pes ?paq))
    )
  )

  (:action dispensa-unitari-ultim
    :parameters (?rob - robot ?cas - casella ?disp - dispensador ?paq - paquet)
    :precondition (and
      (mode-ordenat)
      (robot-at ?rob ?cas)
      (prop-dispensador ?cas ?disp)
      (top-robot ?rob ?paq)
      (on-robot ?paq ?rob)
      (requerit ?paq)
      (requerit-actual ?paq)
      (ultim-requerit ?paq)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on-robot ?paq ?rob))
      (robot-buit ?rob)
      (dispensat ?paq)
      (not (requerit-actual ?paq))
      (decrease (carrega ?rob) (pes ?paq))
    )
  )

  (:action dispensa-pila-mig
    :parameters (?rob - robot ?cas - casella ?disp - dispensador ?paq - paquet ?sota - paquet ?seguent - paquet)
    :precondition (and
      (mode-ordenat)
      (robot-at ?rob ?cas)
      (prop-dispensador ?cas ?disp)
      (top-robot ?rob ?paq)
      (on ?paq ?sota)
      (requerit ?paq)
      (requerit-actual ?paq)
      (seguent-requerit ?paq ?seguent)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on ?paq ?sota))
      (top-robot ?rob ?sota)
      (dispensat ?paq)
      (not (requerit-actual ?paq))
      (requerit-actual ?seguent)
      (decrease (carrega ?rob) (pes ?paq))
    )
  )

  (:action dispensa-pila-ultim
    :parameters (?rob - robot ?cas - casella ?disp - dispensador ?paq - paquet ?sota - paquet)
    :precondition (and
      (mode-ordenat)
      (robot-at ?rob ?cas)
      (prop-dispensador ?cas ?disp)
      (top-robot ?rob ?paq)
      (on ?paq ?sota)
      (requerit ?paq)
      (requerit-actual ?paq)
      (ultim-requerit ?paq)
      (> (energia ?rob) 0)
    )
    :effect (and
      (not (top-robot ?rob ?paq))
      (not (on ?paq ?sota))
      (top-robot ?rob ?sota)
      (dispensat ?paq)
      (not (requerit-actual ?paq))
      (decrease (carrega ?rob) (pes ?paq))
    )
  )
)