export owner_id=ohara1.testnet
export a_id=ada.$owner_id
export b_id=dot.$owner_id
export amm_id=amm.$owner_id
export sim_id=sim.$owner_id
export CONTRACT_FT_ID=ft.$owner_id
export ONE_YOCTO=0.000000000000000000000001
export GAS=55000000000000
export test_id=test.$owner_id
#4m
amm_a_balance=400000000000000
#3m
amm_b_balance=300000000000000
#1m
sim_a_balance=100000000000000
#1m
sim_a_exchange=1000000000000

near="near --nodeUrl https://rpc.testnet.near.org"

near delete $a_id $owner_id
near delete $b_id $owner_id
near delete $amm_id $owner_id
near delete $sim_id $owner_id
near create-account $CONTRACT_FT_ID --masterAccount $owner_id --initialBalance 5
near create-account $test_id --masterAccount $owner_id --initialBalance 5
near create-account $a_id --masterAccount $owner_id --initialBalance 5
near create-account $b_id --masterAccount $owner_id --initialBalance 5
near create-account $amm_id --masterAccount $owner_id --initialBalance 5
near create-account $sim_id --masterAccount $owner_id --initialBalance 5
near deploy --wasmFile out/token-contract.wasm --accountId $CONTRACT_FT_ID 
near deploy --wasmFile out/token-contract.wasm --accountId $a_id 
near deploy --wasmFile out/token-contract.wasm --accountId $b_id 
near deploy --wasmFile out/simple-pool.wasm --accountId $amm_id 



near call $a_id new '{"owner_id": "'$owner_id'", "total_supply": "1000000000000000", "metadata": { "spec": "ft-1.0.0", "name": "ADA Token", "symbol": "ADA", "decimals": 8 }}' --accountId $a_id
near call $b_id new '{"owner_id": "'$owner_id'", "total_supply": "3000000000000000", "metadata": { "spec": "ft-1.0.0", "name": "DOT Token", "symbol": "DOT", "decimals": 8 }}' --accountId $b_id
near call $amm_id new '{"owner_id": "'$owner_id'", "token_ids": ["'$a_id'", "'$b_id'"], "exchange_fee": "300"}' --accountId=$owner_id --gas=$GAS

near call $a_id storage_deposit '{"account_id": "'$amm_id'"}' --accountId=$owner_id --deposit=0.1
near call $b_id storage_deposit '{"account_id": "'$amm_id'"}' --accountId=$owner_id --deposit=0.1
near call $a_id storage_deposit '{"account_id": "'$sim_id'"}' --accountId=$owner_id --deposit=0.1
near call $b_id storage_deposit '{"account_id": "'$sim_id'"}' --accountId=$owner_id --deposit=0.1
near call $a_id storage_deposit '{"account_id": "'$test_id'"}' --accountId=$owner_id --deposit=0.1
near call $b_id storage_deposit '{"account_id": "'$test_id'"}' --accountId=$owner_id --deposit=0.1

near call $a_id ft_transfer_call '{"receiver_id": "'$amm_id'","amount":"'$amm_a_balance'","msg":""}' --accountId=$owner_id --deposit=$ONE_YOCTO --gas=$GAS
near call $b_id ft_transfer_call '{"receiver_id": "'$amm_id'","amount":"'$amm_b_balance'","msg":""}' --accountId=$owner_id --deposit=$ONE_YOCTO --gas=$GAS
near call $a_id ft_transfer '{"receiver_id": "'$sim_id'","amount":"'$sim_a_balance'"}' --accountId=$owner_id --deposit=$ONE_YOCTO --gas=$GAS

#100000000000000
near view $a_id ft_balance_of '{"account_id": "'$sim_id'"}'
#0
near view $b_id ft_balance_of '{"account_id": "'$sim_id'"}'
#400000000000000
near view $a_id ft_balance_of '{"account_id": "'$amm_id'"}'
#300000000000000
near view $b_id ft_balance_of '{"account_id": "'$amm_id'"}'




near call $amm_id register_account '{"account_id": "'$sim_id'"}' --accountId=$owner_id --deposit 0.1 --gas=$GAS

#create account test amm sim
#transfer token to sim and depoist to amm
#contract token A transfer to test 90000000000000
near call $a_id ft_transfer '{"receiver_id": "'$test_id'","amount":"90000000000000"}' --accountId=$owner_id --deposit=$ONE_YOCTO --gas=$GAS
#contract token B transfer to test 170000000000000
near call $b_id ft_transfer '{"receiver_id": "'$test_id'","amount":"170000000000000"}' --accountId=$owner_id --deposit=$ONE_YOCTO --gas=$GAS
#account test deposit to amm
near call $a_id ft_transfer_call '{"receiver_id": "'$amm_id'","amount":"90000000000000","msg":""}' --accountId=$test_id --deposit=$ONE_YOCTO --gas=$GAS
near call $b_id ft_transfer_call '{"receiver_id": "'$amm_id'","amount":"120000000000000","msg":""}' --accountId=$test_id --deposit=$ONE_YOCTO --gas=$GAS

# add liquidity
 near call $amm_id add_liquidity '{"token_in": "'$a_id'", "amount_in": "10000000000000", "token_out": "'$b_id'", "amount_out": "30000000000000"}' --accountId $test_id --deposit $ONE_YOCTO --gas $GAS
# get_account_info
near view $amm_id get_account_info '{"account_id": "'$test_id'"}'
#get_stroage_balance
near view $amm_id storage_balance_of '{"account_id": "'$sim_id'"}'

#remove liquidity
near call $amm_id remove_liquidity '{"amount": "500000000000000"}' --accountId $test_id --deposit $ONE_YOCTO --gas $GAS

#withdraw
near call $amm_id withdraw '{"token_id": "'$a_id'"}' --accountId $test_id --deposit $ONE_YOCTO --gas $GAS