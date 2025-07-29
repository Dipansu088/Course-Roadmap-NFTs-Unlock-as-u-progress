

(define-non-fungible-token course-nft uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-eligible (err u101))
(define-constant err-invalid-level (err u102))

(define-map student-progress principal uint)

;; Mint NFT based on level (1 = Beginner, 2 = Intermediate, 3 = Advanced)
(define-public (mint-nft (level uint))
  (begin
    (asserts! (>= level u1) err-invalid-level)
    (asserts! (<= level u3) err-invalid-level)
    ;; Check if student has reached or surpassed this level
    (let ((progress (default-to u0 (map-get? student-progress tx-sender))))
      (asserts! (>= progress level) err-not-eligible)
      (try! (nft-mint? course-nft level tx-sender))
      (ok true))))

;; Update student's course progress (only contract owner can update)
(define-public (update-progress (student principal) (level uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (>= level u1) err-invalid-level)
    (asserts! (<= level u3) err-invalid-level)
    (map-set student-progress student level)
    (ok true)))
