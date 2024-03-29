const axios = require('axios');

const graphqlEndpoint = 'https://api.devnet.aptoslabs.com/v1/graphql';
const graphqlQuery = {
    query: `
    query MyQuery {
      events(
        distinct_on: type
        where: {type: {_eq: "0x852c844262fa204073c3d7ecc19fb352d23ed0a3022ba2b34efff60c82ec3d88::DaoFactory::DaoCreationEvent"}}
      ) {
        account_address
        creation_number
        event_index
        indexed_type
        sequence_number
        transaction_block_height
        transaction_version
        type
        data
      }
    }
  `
};

axios.post(graphqlEndpoint, graphqlQuery, {
    headers: {
        'Content-Type': 'application/json',
        // 如有需要，添加更多的 HTTP 头部
    }
})
    .then((response) => {
        // 处理响应数据
        console.log(response.data);
    })
    .catch((error) => {
        // 处理错误
        console.error('Error:', error);
    });
