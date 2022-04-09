use near_jsonrpc_client::methods;
use near_jsonrpc_client::JsonRpcClient;
use near_primitives::account::id::AccountId;
use near_primitives::types::{BlockReference, Finality};
use near_primitives::views::BlockView;

async fn query_mainnet_final_author() -> Result<AccountId, Box<dyn std::error::Error>> {
    let client = JsonRpcClient::connect("https://rpc.mainnet.near.org");

    let request = methods::block::RpcBlockRequest {
        block_reference: BlockReference::Finality(Finality::Final),
    };

    let response = client.call(request).await?;

    Ok(response.author)
}

async fn query_testnet_final_author() -> Result<AccountId, Box<dyn std::error::Error>> {
    let client = JsonRpcClient::connect("https://rpc.mainnet.near.org");

    let request = methods::block::RpcBlockRequest {
        block_reference: BlockReference::Finality(Finality::Final),
    };

    let response = client.call(request).await?;

    Ok(response.author)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    match tokio::join!(query_mainnet_final_author(), query_testnet_final_author()) {
        (Ok(mainnet_author), Ok(testnet_author)) => {
            if mainnet_author == testnet_author {
                println!("The last author of mainnet and testnet are the same. {mainnet_author:?}");
            } else {
                println!("The last author of mainnet and testnet are different. mainnet author: {mainnet_author:?}, testnet author: {testnet_author:?}");
            }
        }
        _ => {
            eprintln!("Fail to get the last author of mainnet or testnet");
        }
    };
    Ok(())
}
