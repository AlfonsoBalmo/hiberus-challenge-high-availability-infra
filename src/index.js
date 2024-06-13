const app = require('./app');
const config = require('./config');

exports.handler = async (event, context) => {
    console.log("Received event:", JSON.stringify(event, null, 2));

    return new Promise((resolve, reject) => {
        app.listen(config.port, () => {
            console.log(`Server running on port ${config.port}`);
            resolve({
                statusCode: 200,
                body: JSON.stringify({ message: 'Server started' })
            });
        });
    });
};
