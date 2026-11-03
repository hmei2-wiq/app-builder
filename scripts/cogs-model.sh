#!/usr/bin/env bash
# cogs-model.sh — unit-economics model for the PLG free→paid funnel.
#
# Gates the Phase 2 decision in openspec/context/shipworthy-strategy.md: is a free
# ideation+preview tier converting to $49/mo Launch actually viable, given that
# you pay AI-inference + hosting COGS for EVERY free user but only a few percent
# convert? This makes the assumption explicit and runs a sensitivity sweep.
#
# Model (steady state, per monthly cohort; CAC/LTV are per-free-user invariant
# of cohort size):
#   per_free_user_cost = runs * cost_per_run + preview_rate * preview_cost
#   CAC                = per_free_user_cost / conv_rate
#   LTV (gross margin) = (price - launch_cogs) / churn
#   LTV:CAC            = LTV / CAC
#   break-even conv    = per_free_user_cost * churn / (price - launch_cogs)
#   monthly contribution(S) = paying_base*(price-launch_cogs) - S*per_free_user_cost
#                             where paying_base = S*conv_rate/churn
#
# Usage: scripts/cogs-model.sh [--flags] [--json] [--sweep]
#   --signups N         free signups / month            (default 5000)
#   --runs N            ideation runs / free user        (default 3)
#   --cost-per-run $    LLM cost per ideation run        (default 0.50)
#   --preview-rate F    frac of free users who deploy    (default 0.40)
#   --preview-cost $    hosting / preview app / month    (default 1.00)
#   --conv F            free→Launch conversion rate      (default 0.03)
#   --price $           Launch monthly price             (default 49)
#   --launch-cogs $     COGS per paying user / month     (default 12)
#   --churn F           monthly churn of paying base     (default 0.05)
#   --json              machine-readable output
#   --sweep             print a conv-rate × cost-per-run sensitivity grid
#
# Verdict: LTV:CAC >= 3 HEALTHY, >= 1 MARGINAL, < 1 UNDERWATER.

set -uo pipefail

S=5000 RUNS=3 CPR=0.50 PVR=0.40 PVC=1.00 CONV=0.03 PRICE=49 LCOGS=12 CHURN=0.05
OUTPUT=human SWEEP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --signups)     S="$2"; shift 2;;
    --runs)        RUNS="$2"; shift 2;;
    --cost-per-run) CPR="$2"; shift 2;;
    --preview-rate) PVR="$2"; shift 2;;
    --preview-cost) PVC="$2"; shift 2;;
    --conv)        CONV="$2"; shift 2;;
    --price)       PRICE="$2"; shift 2;;
    --launch-cogs) LCOGS="$2"; shift 2;;
    --churn)       CHURN="$2"; shift 2;;
    --json)        OUTPUT=json; shift;;
    --sweep)       SWEEP=1; shift;;
    -h|--help)     grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *)             echo "unknown arg: $1" >&2; exit 2;;
  esac
done

# compute <conv> <cost_per_run> -> JSON object
compute() {
  awk -v S="$S" -v runs="$RUNS" -v cpr="$2" -v pvr="$PVR" -v pvc="$PVC" \
      -v conv="$1" -v price="$PRICE" -v lcogs="$LCOGS" -v churn="$CHURN" 'BEGIN{
    pfu  = runs*cpr + pvr*pvc;            # per free user cost
    gm   = price - lcogs;                 # gross margin per paying user / mo
    cac  = (conv>0)? pfu/conv : 1e12;
    ltv  = (churn>0)? gm/churn : 1e12;
    ratio= (cac>0)? ltv/cac : 0;
    be   = (gm>0)? pfu*churn/gm : 1e12;   # break-even conv (ratio=1)
    be3  = 3*be;                          # conv for ratio=3
    paybase = S*conv/churn;
    contrib = paybase*gm - S*pfu;         # steady-state monthly contribution
    verdict = (ratio>=3)?"HEALTHY":((ratio>=1)?"MARGINAL":"UNDERWATER");
    printf "{\"conv\":%.4f,\"cost_per_run\":%.4f,\"per_free_user_cost\":%.4f,\"cac\":%.2f,\"ltv\":%.2f,\"ltv_cac\":%.2f,\"breakeven_conv\":%.4f,\"target_conv_3x\":%.4f,\"paying_base\":%.0f,\"monthly_contribution\":%.0f,\"verdict\":\"%s\"}\n",
      conv,cpr,pfu,cac,ltv,ratio,be,be3,paybase,contrib,verdict;
  }'
}

MAIN="$(compute "$CONV" "$CPR")"

if [[ "$OUTPUT" == "json" ]]; then
  if [[ "$SWEEP" == "1" ]]; then
    { for c in 0.01 0.02 0.03 0.05 0.08; do for k in 0.50 1.50 3.00; do compute "$c" "$k"; done; done; } \
      | jq -s --argjson base "$MAIN" '{base:$base, sweep:.}'
  else
    printf '%s\n' "$MAIN" | jq .
  fi
  exit 0
fi

# human
fmt() { printf '%s' "$MAIN" | jq -r "$1"; }
echo "═══════════════════════════════════════════════════════════"
echo "  PLG Free→Paid Unit Economics   (Phase 2 gate)"
echo "═══════════════════════════════════════════════════════════"
printf "  Inputs: %s signups/mo · %s runs/user @ \$%s · preview %s%% @ \$%s\n" "$S" "$RUNS" "$CPR" "$(awk -v x="$PVR" 'BEGIN{printf "%.0f",x*100}')" "$PVC"
printf "          conv %s%% · price \$%s · paid COGS \$%s · churn %s%%\n" "$(awk -v x="$CONV" 'BEGIN{printf "%.1f",x*100}')" "$PRICE" "$LCOGS" "$(awk -v x="$CHURN" 'BEGIN{printf "%.0f",x*100}')"
echo "───────────────────────────────────────────────────────────"
printf "  Cost per free user ........ \$%s\n" "$(fmt .per_free_user_cost)"
printf "  CAC (per paying customer) . \$%s\n" "$(fmt .cac)"
printf "  LTV (gross margin) ........ \$%s\n" "$(fmt .ltv)"
printf "  LTV : CAC ................. %sx\n" "$(fmt .ltv_cac)"
printf "  Break-even conv (1x) ...... %s%%\n" "$(awk -v x="$(fmt .breakeven_conv)" 'BEGIN{printf "%.2f",x*100}')"
printf "  Conv needed for 3x ........ %s%%\n" "$(awk -v x="$(fmt .target_conv_3x)" 'BEGIN{printf "%.2f",x*100}')"
printf "  Steady-state paying base .. %s users\n" "$(fmt .paying_base)"
printf "  Monthly contribution ...... \$%s\n" "$(fmt .monthly_contribution)"
printf "  VERDICT ................... %s\n" "$(fmt .verdict)"
echo "═══════════════════════════════════════════════════════════"

if [[ "$SWEEP" == "1" ]]; then
  echo "  Sensitivity — LTV:CAC by conversion rate × cost/ideation-run"
  printf "  %-8s | %8s %8s %8s\n" "conv\\run" "\$0.50" "\$1.50" "\$3.00"
  echo "  ---------|---------------------------"
  for c in 0.01 0.02 0.03 0.05 0.08; do
    row="$(awk -v x="$c" 'BEGIN{printf "%.0f%%",x*100}')"
    line=$(printf "  %-8s |" "$row")
    for k in 0.50 1.50 3.00; do
      r="$(compute "$c" "$k" | jq -r '.ltv_cac')"
      line="$line $(printf '%8s' "${r}x")"
    done
    echo "$line"
  done
  echo "  (HEALTHY >= 3.0x · MARGINAL 1.0–3.0x · UNDERWATER < 1.0x)"
  echo "═══════════════════════════════════════════════════════════"
fi
