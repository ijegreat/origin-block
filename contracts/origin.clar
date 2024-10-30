;; Supply Chain Management Smart Contract

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-product-exists (err u101))
(define-constant err-product-not-found (err u102))
(define-constant err-invalid-status (err u103))

;; Define data maps
(define-map products
  { product-id: (string-ascii 32) }
  {
    owner: principal,
    manufacturer: principal,
    status: (string-ascii 20),
    quality-score: uint,
    quantity: uint,
    timestamp: uint
  }
)

(define-map product-history
  { product-id: (string-ascii 32), index: uint }
  {
    owner: principal,
    status: (string-ascii 20),
    quality-score: uint,
    quantity: uint,
    timestamp: uint
  }
)

;; Define data variables
(define-data-var next-index uint u0)

;; Private functions
(define-private (is-authorized (caller principal))
  (or (is-eq caller contract-owner)
      (is-some (index-of (list contract-owner) caller)))
)

(define-private (validate-status (status (string-ascii 20)))
  (is-some (index-of (list "manufactured" "in-transit" "delivered" "sold") status))
)

(define-private (add-to-history (product-id (string-ascii 32)) (owner principal) (status (string-ascii 20)) (quality-score uint) (quantity uint))
  (let ((index (var-get next-index)))
    (map-set product-history
      { product-id: product-id, index: index }
      {
        owner: owner,
        status: status,
        quality-score: quality-score,
        quantity: quantity,
        timestamp: block-height
      }
    )
    (var-set next-index (+ index u1))
    index
  )
)

;; Public functions
(define-public (register-product (product-id (string-ascii 32)) (quantity uint))
  (let ((caller tx-sender))
    (if (is-authorized caller)
      (if (is-none (map-get? products { product-id: product-id }))
        (begin
          (map-set products
            { product-id: product-id }
            {
              owner: caller,
              manufacturer: caller,
              status: "manufactured",
              quality-score: u100,
              quantity: quantity,
              timestamp: block-height
            }
          )
          (add-to-history product-id caller "manufactured" u100 quantity)
          (ok true)
        )
        err-product-exists
      )
      err-not-authorized
    )
  )
)

(define-public (transfer-ownership (product-id (string-ascii 32)) (new-owner principal))
  (let ((product (unwrap! (map-get? products { product-id: product-id }) err-product-not-found))
        (caller tx-sender))
    (if (is-eq (get owner product) caller)
      (begin
        (map-set products
          { product-id: product-id }
          (merge product { owner: new-owner })
        )
        (add-to-history product-id new-owner (get status product) (get quality-score product) (get quantity product))
        (ok true)
      )
      err-not-authorized
    )
  )
)

(define-public (update-status (product-id (string-ascii 32)) (new-status (string-ascii 20)))
  (let ((product (unwrap! (map-get? products { product-id: product-id }) err-product-not-found))
        (caller tx-sender))
    (if (and (is-eq (get owner product) caller) (validate-status new-status))
      (begin
        (map-set products
          { product-id: product-id }
          (merge product { status: new-status })
        )
        (add-to-history product-id caller new-status (get quality-score product) (get quantity product))
        (ok true)
      )
      (if (not (validate-status new-status))
        err-invalid-status
        err-not-authorized
      )
    )
  )
)

(define-public (update-quality (product-id (string-ascii 32)) (quality-score uint))
  (let ((product (unwrap! (map-get? products { product-id: product-id }) err-product-not-found))
        (caller tx-sender))
    (if (is-authorized caller)
      (begin
        (map-set products
          { product-id: product-id }
          (merge product { quality-score: quality-score })
        )
        (add-to-history product-id (get owner product) (get status product) quality-score (get quantity product))
        (ok true)
      )
      err-not-authorized
    )
  )
)

(define-public (update-quantity (product-id (string-ascii 32)) (quantity uint))
  (let ((product (unwrap! (map-get? products { product-id: product-id }) err-product-not-found))
        (caller tx-sender))
    (if (is-eq (get owner product) caller)
      (begin
        (map-set products
          { product-id: product-id }
          (merge product { quantity: quantity })
        )
        (add-to-history product-id caller (get status product) (get quality-score product) quantity)
        (ok true)
      )
      err-not-authorized
    )
  )
)

;; Read-only functions
(define-read-only (get-product (product-id (string-ascii 32)))
  (map-get? products { product-id: product-id })
)

(define-read-only (get-product-history (product-id (string-ascii 32)) (index uint))
  (map-get? product-history { product-id: product-id, index: index })
)

(define-read-only (get-latest-history-index)
  (- (var-get next-index) u1)
)