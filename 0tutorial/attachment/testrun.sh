#!/bin/bash

echo "Test Run launced, ~3 minutes."

R=$PWD
TMLIM=60
MAINLOG="/dev/null"

rm *.log */*.log */*/*.log */*/*/*.log */*/*/*/*.log 2>/dev/null
echo "Test Run" >$MAINLOG

cd $R/gnump/2-helloworld
glpsol -m helloworld.mod --log helloworld.log >>$MAINLOG || echo FAIL-gnump-2-A
glpsol -m helloworld-int.mod --log helloworld-int.log >>$MAINLOG || echo FAIL-gnump-2-B

cd $R/eqsystem/1-simple
glpsol -m eqsystem-straightforward.mod --log eqsystem-straightforward.log >>$MAINLOG || echo FAIL-eqsystem-1-A
glpsol -m eqsystem-aligned.mod --log eqsystem-aligned.log >>$MAINLOG || echo FAIL-eqsystem-1-B

cd $R/eqsystem/2-modifications
glpsol -m eqsystem-modifications.mod --log eqsystem-modifications.log >>$MAINLOG || echo FAIL-eqsystem-2-A

cd $R/eqsystem/3-parametrization
glpsol -m eqsystem-parametrization-rhs.mod --log eqsystem-parametrization-rhs.log >>$MAINLOG || echo FAIL-eqsystem-3-A
glpsol -m eqsystem-parametrization-full.mod --log eqsystem-parametrization-full.log >>$MAINLOG || echo FAIL-eqsystem-3-B

cd $R/eqsystem/4-data-blocks
glpsol -m eqsystem-data-blocks-rhs.mod -d eqsystem-data-blocks-rhs.dat --log eqsystem-data-blocks-rhs.log >>$MAINLOG || echo FAIL-eqsystem-4-A
glpsol -m eqsystem-data-blocks-full.mod -d eqsystem-data-blocks-full-A.dat --log eqsystem-data-blocks-full-A.log >>$MAINLOG || echo FAIL-eqsystem-4-B
glpsol -m eqsystem-data-blocks-full.mod -d eqsystem-data-blocks-full-B-ERROR-novalue.dat --log eqsystem-data-blocks-full-B-ERROR-novalue.log >>$MAINLOG && echo FAIL-eqsystem-4-C

cd $R/eqsystem/5-indexing
glpsol -m eqsystem-indexing.mod -d eqsystem-indexing.dat --log eqsystem-indexing.log >>$MAINLOG || echo FAIL-eqsystem-5-A

cd $R/eqsystem/6-data-options
glpsol -m eqsystem-data-options-defaulted.mod -d eqsystem-data-options-defaulted.dat --log eqsystem-data-options-defaulted.log >>$MAINLOG || echo FAIL-eqsystem-6-A
glpsol -m eqsystem-data-options-defaulted.mod -d eqsystem-data-options-defaulted-matrix.dat --log eqsystem-data-options-defaulted-matrix.log >>$MAINLOG || echo FAIL-eqsystem-6-B
glpsol -m eqsystem-data-options-wrongindex.mod -d eqsystem-data-options-wrongindex-A.dat --log eqsystem-data-options-wrongindex-A.log >>$MAINLOG || echo FAIL-eqsystem-6-C
glpsol -m eqsystem-data-options-wrongindex.mod -d eqsystem-data-options-wrongindex-B-ERROR-outofdomain.dat --log eqsystem-data-options-wrongindex-B-ERROR-outofdomain.log >>$MAINLOG && echo FAIL-eqsystem-6-D

cd $R/eqsystem/7-columns
glpsol -m eqsystem-columns.mod -d eqsystem-columns.dat --log eqsystem-columns.log >>$MAINLOG || echo FAIL-eqsystem-7-A

cd $R/eqsystem/8-error-min
glpsol -m eqsystem-original.mod -d eqsystem-overspecified.dat --log eqsystem-overspecified-original.log >>$MAINLOG || echo FAIL-eqsystem-8-A
glpsol -m eqsystem-error-min.mod -d eqsystem-overspecified.dat --log eqsystem-overspecified-error-min.log >>$MAINLOG || echo FAIL-eqsystem-8-B

cd $R/production/1-basic
glpsol -m production-basic-straightforward.mod --log production-basic-straightforward.log >>$MAINLOG || echo FAIL-production-1-A
glpsol -m production-basic-indexed.mod -d production-basic.dat --log production-basic-indexed.log >>$MAINLOG || echo FAIL-production-1-B
glpsol -m production-basic-indexed-shorter.mod -d production-basic.dat --log production-basic-indexed-shorter.log >>$MAINLOG || echo FAIL-production-1-C

cd $R/production/2-limits
glpsol -m production-limits.mod -d production-limits.dat --log production-limits.log >>$MAINLOG || echo FAIL-production-2-A
glpsol -m production-limits-shorter.mod -d production-limits.dat --log production-limits-shorter.log >>$MAINLOG || echo FAIL-production-2-B
glpsol -m production-limits-shortest.mod -d production-limits.dat --log production-limits-shortest.log >>$MAINLOG || echo FAIL-production-2-C

cd $R/production/3-max-of-min
glpsol -m production-max-of-min.mod -d production-max-of-min-A.dat --log production-max-of-min-A.log >>$MAINLOG || echo FAIL-production-3-A
glpsol -m production-max-of-min.mod -d production-max-of-min-B.dat --log production-max-of-min-B.log >>$MAINLOG || echo FAIL-production-3-B

cd $R/production/4-raw-costs
glpsol -m production-raw-costs.mod -d production-raw-costs.dat --log production-raw-costs.log >>$MAINLOG || echo FAIL-production-4-A

cd $R/production/5-diet
glpsol -m production-diet.mod -d production-diet.dat --log production-diet.log >>$MAINLOG || echo FAIL-production-5-A

cd $R/production/6-arbitrary-recipes
glpsol -m production-arbitrary-recipes.mod -d production-arbitrary-recipes-raw-costs.dat --log production-arbitrary-recipes-raw-costs.log >>$MAINLOG || echo FAIL-production-6-A
glpsol -m production-arbitrary-recipes.mod -d production-arbitrary-recipes-diet.dat --log production-arbitrary-recipes-diet.log >>$MAINLOG || echo FAIL-production-6-B
glpsol -m production-arbitrary-recipes.mod -d production-arbitrary-recipes-arbitrary.dat --log production-arbitrary-recipes-arbitrary.log >>$MAINLOG || echo FAIL-production-6-C

cd $R/production/7-orders
glpsol -m production-orders.mod -d production-orders-A.dat --log production-orders-A.log >>$MAINLOG || echo FAIL-production-7-A
glpsol -m production-orders.mod -d production-orders-B.dat --log production-orders-B.log >>$MAINLOG || echo FAIL-production-7-B
glpsol -m production-orders.mod -d production-orders-C.dat --log production-orders-C.log >>$MAINLOG || echo FAIL-production-7-C
glpsol -m production-orders.mod -d production-orders-C.dat --log production-orders-C-nomip.log --nomip >>$MAINLOG || echo FAIL-production-7-D

cd $R/transportation/1-basic
glpsol -m transportation-basic.mod -d transportation-basic.dat --log transportation-basic.log >>$MAINLOG || echo FAIL-transportation-1-A

cd $R/transportation/2-connections
glpsol -m transportation-connections.mod -d transportation-connections.dat --log transportation-connections.log >>$MAINLOG || echo FAIL-transportation-2-A
glpsol -m transportation-specific.mod -d transportation-connections.dat --log transportation-specific.log >>$MAINLOG || echo FAIL-transportation-2-B

cd $R/transportation/3-increasing-rates
glpsol -m transportation-increasing-rates.mod -d transportation-increasing-rates.dat --log transportation-increasing-rates.log >>$MAINLOG || echo FAIL-transportation-3-A

cd $R/transportation/4-economy-of-scale
glpsol -m transportation-economy-of-scale-naive.mod -d transportation-economy-of-scale.dat --log transportation-economy-of-scale-naive.log >>$MAINLOG || echo FAIL-transportation-4-A
glpsol -m transportation-economy-of-scale.mod -d transportation-economy-of-scale.dat --log transportation-economy-of-scale.log >>$MAINLOG || echo FAIL-transportation-4-B

cd $R/transportation/5-fixed-costs
glpsol -m transportation-fixed-costs.mod -d transportation-original.dat --log transportation-original.log >>$MAINLOG || echo FAIL-transportation-5-A
glpsol -m transportation-fixed-costs.mod -d transportation-fixed-costs.dat --log transportation-fixed-costs.log >>$MAINLOG || echo FAIL-transportation-5-B

cd $R/transportation/6-penalties
glpsol -m transportation-penalties-A.mod -d transportation-penalties-small.dat --log transportation-penalties-A-small.log --xcheck >>$MAINLOG || echo FAIL-transportation-6-A
glpsol -m transportation-penalties-B.mod -d transportation-penalties-small.dat --log transportation-penalties-B-small.log --xcheck >>$MAINLOG || echo FAIL-transportation-6-B
glpsol -m transportation-penalties-A.mod -d transportation-penalties-large.dat --log transportation-penalties-A-large.log --xcheck >>$MAINLOG || echo FAIL-transportation-6-C
glpsol -m transportation-penalties-B.mod -d transportation-penalties-large.dat --log transportation-penalties-B-large.log --xcheck >>$MAINLOG || echo FAIL-transportation-6-D

cd $R/transportation/7-mid-level
glpsol -m transportation-mid-level.mod -d transportation-mid-level-small-establish.dat --log transportation-mid-level-small-establish.log >>$MAINLOG || echo FAIL-transportation-7-A
glpsol -m transportation-mid-level.mod -d transportation-mid-level-large-establish.dat --log transportation-mid-level-large-establish.log >>$MAINLOG || echo FAIL-transportation-7-B

cd $R/milp/1-knapsack
glpsol -m knapsack-basic.mod -d knapsack-basic.dat --log knapsack-basic.log >>$MAINLOG || echo FAIL-milp-1-A
glpsol -m knapsack-basic.mod -d knapsack-basic.dat --log knapsack-basic-nomip.log --nomip >>$MAINLOG || echo FAIL-milp-1-B
glpsol -m knapsack-relaxed.mod -d knapsack-basic.dat --log knapsack-relaxed.log --nomip >>$MAINLOG || echo FAIL-milp-1-C
glpsol -m knapsack-multiway.mod -d knapsack-multiway.dat --log knapsack-multiway.log >>$MAINLOG || echo FAIL-milp-1-A

cd $R/milp/2-tiling
glpsol -m tiling.mod -d tiling-small.dat --log tiling-small.log >>$MAINLOG || echo FAIL-milp-2-A
glpsol -m tiling.mod -d tiling-medium.dat --log tiling-medium.log >>$MAINLOG || echo FAIL-milp-2-B
glpsol -m tiling.mod -d tiling-large.dat --log tiling-large.log --tmlim $TMLIM >>$MAINLOG || echo FAIL-milp-2-C
glpsol -m tiling.mod -d tiling-large.dat --log tiling-large-options.log --fpump --cuts --tmlim $TMLIM >>$MAINLOG || echo FAIL-milp-2-D

cd $R/milp/3-assignment
glpsol -m assignment.mod -d assignment-basic.dat --log assignment-basic.log >>$MAINLOG || echo FAIL-milp-3-A
glpsol -m assignment.mod -d assignment-basic.dat --log assignment-basic-nomip.log --nomip >>$MAINLOG || echo FAIL-milp-3-B
glpsol -m assignment.mod -d assignment-fixing-A.dat --log assignment-fixing-A.log >>$MAINLOG || echo FAIL-milp-3-C
glpsol -m assignment.mod -d assignment-fixing-B.dat --log assignment-fixing-B.log >>$MAINLOG || echo FAIL-milp-3-D

cd $R/milp/4-graphs
glpsol -m shortest-path.mod -d shortest-path.dat --log shortest-path.log >>$MAINLOG || echo FAIL-milp-4-A
glpsol -m cheapest-tree.mod -d cheapest-tree.dat --log cheapest-tree.log >>$MAINLOG || echo FAIL-milp-4-B

cd $R/milp/5-tsp
glpsol -m tsp.mod -d tsp.dat --log tsp.log >>$MAINLOG || echo FAIL-milp-5-A

echo FINISHED!
