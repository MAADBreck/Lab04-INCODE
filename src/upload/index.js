const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { v4: uuidv4 } = require("uuid");
const s3 = new S3Client();

exports.handler = async (event) => {
  try {
   
    const body = JSON.parse(event.body);
    const buffer = Buffer.from(body.image, "base64");
    const fileName = `${uuidv4()}.png`;

    await s3.send(new PutObjectCommand({
      Bucket: process.env.S3_BUCKET,
      Key: `${process.env.UPLOAD_PREFIX}${fileName}`,
      Body: buffer,
      ContentType: "image/png"
    }));

    return { statusCode: 200, body: JSON.stringify({ message: "Subida exitosa", file: fileName }) };
  } catch (error) {
    return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
  }
};