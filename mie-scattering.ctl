(define-param r 0.015) ;; radius of sphere

(define wvl-min 0.4); wavelength of 400 nm
(define wvl-max 0.7);wavelength of 700 nm

(define frq-min (/ wvl-max));frequency of 400 nm
(define frq-max (/ wvl-min));frequency of 700 nm
(define frq-cen (* 0.5 (+ frq-min frq-max))) ; center frequency for gaussian pulse
(define dfrq (- frq-max frq-min)) ; width for gaussian pulse 
(define nfrq 100)

;; at least 8 pixels per smallest wavelength, i.e. (floor (/ 8 wvl-min))
(set-param! resolution 45)

(define dpml (* 0.5 wvl-max))
(define dair (* 0.5 wvl-max))

(define boundary-layers (list (make pml (thickness dpml)))) ; setting up pml layers
(set! pml-layers boundary-layers)

(define symm (list (make mirror-sym (direction Y))
                   (make mirror-sym (direction Z) (phase -1)))) 
(set! symmetries symm) ; setting symmetries 

(define s (* 2 (+ dpml dair r)))
(define cell (make lattice (size s s s)));compuatational cell of sie s*s*s in 3D
(set! geometry-lattice cell)

;; (is-integrated? true) necessary for any planewave source extending into PML
(define pw-src (make source
                 (src (make gaussian-src (frequency frq-cen) (fwidth dfrq) (is-integrated? true)))
                 (center (+ (* -0.5 s) dpml) 0 0)
                 (size 0 s s)
                 (component Ez)));a plane wave with gaussian distribution 
(set! sources (list pw-src))

(set! k-point (vector3 0))


; measuring the incident flux through the cuboid which encloses the gold nanosphere
(define box-x1 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center (- r) 0 0) (size 0 (* 2 r) (* 2 r)))))
(define box-x2 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center (+ r) 0 0) (size 0 (* 2 r) (* 2 r)))))
(define box-y1 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 (- r) 0) (size (* 2 r) 0 (* 2 r)))))
(define box-y2 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 (+ r) 0) (size (* 2 r) 0 (* 2 r)))))
(define box-z1 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 0 (- r)) (size (* 2 r) (* 2 r) 0))))
(define box-z2 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 0 (+ r)) (size (* 2 r) (* 2 r) 0))))

(run-sources+ 10)

(display-fluxes box-x1 box-x2 box-y1 box-y2 box-z1 box-z2)

(save-flux "box-x1-flux" box-x1)
(save-flux "box-x2-flux" box-x2)
(save-flux "box-y1-flux" box-y1)
(save-flux "box-y2-flux" box-y2)
(save-flux "box-z1-flux" box-z1)
(save-flux "box-z2-flux" box-z2)

(reset-meep)
; initialising the geometry with sphere and covering the sphere with a cuboidal layer of acetone
(set! geometry (list
                (make block (center 0) (size 0.060 0.060 0.060) (material (make medium(epsilon         1.8496))))
                 (make sphere 
                 (material Au) (radius r)(center 0))))


(set! geometry-lattice cell)

(set! pml-layers boundary-layers)

(set! symmetries symm)

(set! sources (list pw-src))

(set! k-point (vector3 0))
; measuring the flux through the cuboidal shape which perfectly encloses the gold nanosphere
(define box-x1 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center (- r) 0 0) (size 0 (* 2 r) (* 2 r)))))
(define box-x2 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center (+ r) 0 0) (size 0 (* 2 r) (* 2 r)))))
(define box-y1 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 (- r) 0) (size (* 2 r) 0 (* 2 r)))))
(define box-y2 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 (+ r) 0) (size (* 2 r) 0 (* 2 r)))))
(define box-z1 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 0 (- r)) (size (* 2 r) (* 2 r) 0))))
(define box-z2 (add-flux frq-cen dfrq nfrq
                         (make flux-region (center 0 0 (+ r)) (size (* 2 r) (* 2 r) 0))))



(run-sources+ 100(at-beginning output-epsilon) )

(display-fluxes box-x1 box-x2 box-y1 box-y2 box-z1 box-z2)
