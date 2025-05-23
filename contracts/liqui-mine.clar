;; Define SIP-010 Token Trait directly in this contract
(define-trait sip-010-token-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (balance-of (principal) (response uint uint))
  )
)

;; -------------------------------
;; Constants & Data Variables
;; -------------------------------
(define-constant contract-owner tx-sender)
(define-constant ERR_NO_STAKE u100)
(define-constant ERR_INVALID_AMOUNT u101)
(define-constant ERR_INSUFFICIENT_REWARD_POOL u102)
(define-constant ERR_REWARD_TOKEN_NOT_SET u103)
(define-constant ERR_TRANSFER_FAILED u104)
(define-constant ERR_UNAUTHORIZED u105)

(define-data-var total-staked uint u0)
(define-data-var reward-pool uint u0)
(define-data-var reward-token (optional principal) none)

(define-map stakes 
  { user: principal }
  { amount: uint, start-time: uint }
)

(define-private (calculate-reward (amount uint) (duration uint))
  (let (
    (rate u1) ;; Define your reward rate here, e.g., 1 token per block per staked amount
  )
    (* amount (* duration rate))
  )
)

(define-private (process-unstake (user principal) (amount uint) (staked-amount uint) (start-time uint) (reward-token-contract <sip-010-token-trait>))
  (let (
    (duration (- stacks-block-height start-time))
    (reward (calculate-reward amount duration))
    (remaining-stake (- staked-amount amount))
  )
    (begin
      (try! (as-contract (stx-transfer? amount tx-sender user)))
      (var-set total-staked (- (var-get total-staked) amount))
      (var-set reward-pool (- (var-get reward-pool) reward))
      (if (> remaining-stake u0)
        (map-set stakes 
          { user: user }
          { amount: remaining-stake, start-time: stacks-block-height }
        )
        (map-delete stakes { user: user })
      )
      (try! (as-contract 
        (contract-call? 
          reward-token-contract
          transfer 
          reward 
          tx-sender 
          user 
          none)))
      (ok true)
    )
  )
)

(define-public (unstake (amount uint) (reward-token-contract <sip-010-token-trait>))
  (let (
    (stake-data (unwrap! (map-get? stakes { user: tx-sender }) (err ERR_NO_STAKE)))
    (staked-amount (get amount stake-data))
    (start-time (get start-time stake-data))
  )
    (begin
      (asserts! (<= amount staked-amount) (err ERR_INVALID_AMOUNT))
      (asserts! (<= (calculate-reward amount (- stacks-block-height start-time)) (var-get reward-pool)) (err ERR_INSUFFICIENT_REWARD_POOL))
      (try! (process-unstake tx-sender amount staked-amount start-time reward-token-contract))
      (ok true)
    )
  )
)

;; Add a stake function for completeness
(define-public (stake (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let (
      (current-stake (default-to { amount: u0, start-time: stacks-block-height } 
                      (map-get? stakes { user: tx-sender })))
      (current-amount (get amount current-stake))
    )
      (map-set stakes 
        { user: tx-sender }
        { amount: (+ current-amount amount), start-time: stacks-block-height }
      )
      (var-set total-staked (+ (var-get total-staked) amount))
      (ok true)
    )
  )
)

;; Set reward token
(define-public (set-reward-token (token-principal principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err ERR_UNAUTHORIZED)) ;; Only contract owner can set token
    (var-set reward-token (some token-principal))
    (ok true)
  )
)

;; Add rewards to the pool
(define-public (add-rewards (amount uint) (reward-token-contract <sip-010-token-trait>))
  (begin
    (try! (contract-call? reward-token-contract transfer amount tx-sender (as-contract tx-sender) none))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-total-staked)
  (ok (var-get total-staked))
)

(define-read-only (get-reward-pool)
  (ok (var-get reward-pool))
)

(define-read-only (get-user-stake (user principal))
  (ok (default-to { amount: u0, start-time: u0 } (map-get? stakes { user: user })))
)

(define-read-only (get-estimated-reward (user principal))
  (let (
    (stake-data (default-to { amount: u0, start-time: u0 } (map-get? stakes { user: user })))
    (staked-amount (get amount stake-data))
    (start-time (get start-time stake-data))
    (duration (- stacks-block-height start-time))
  )
    (ok (calculate-reward staked-amount duration))
  )
)
