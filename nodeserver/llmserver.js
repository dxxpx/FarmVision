import { GoogleGenerativeAI } from "@google/generative-ai";
import { Console } from "console";
const genAI = new GoogleGenerativeAI("AIzaSyBdM-zkMxxQhCkvept_nv0BIXtUTEwTOZ8");
import { createRequire } from "module";
const require = createRequire(import.meta.url);
const http = require("node:http");
const express = require("express");
const app = express();
import multer from "multer";
const port = 3000;
const { Server } = require("ws");
app.use(express.json());

// Set up multer for handling multipart form data (images)
const upload = multer({ dest: "uploads/" });

var gemini_reply = "Loading";
async function GeminiAi(params) {
  try {
    const generation_config = {
      temperature: 1,
      top_p: 0.95,
      top_k: 16,
      max_output_tokens: 200,
      response_mime_type: "application/json",
    };

    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-flash",
      generation_config,
    });

    const prompt = params;
    const result = await model.generateContent(prompt);
    const response = await result.response;
    gemini_reply = await response.text();
    console.log(response.text());
  } catch (error) {
    console.log("Error inside GeminiAI function : ", error);
  }
}

app.listen(port, () => {
  console.log("sever is running on http://192.168.177.89:%d/api/data", port);
});

app.get("/api/data", (req, res) => {
  res.status(200).send("Hey, You are in my backend!!!");
});

app.post("/api/data", async (req, res) => {
  try {
    console.log("Request from app : ", req.body);
    const user_prompt = req.body.prompt;
    if (!user_prompt) {
      throw new Error("No prompt provided");
    }
    const image = req.file;
    if (image) {
      console.log("Image uploaded: ", image.path);
      // You can process the image if necessary
    } else {
      console.log("No image uploaded");
    }

    await GeminiAi(user_prompt);

    res.status(200).json({
      success: true,
      status_code: 200,
      message: gemini_reply,
      // message: "hello , Replied",
      user_prompt: req.body,
      // user_prompt: "User prompt",
    });
  } catch (error) {
    console.log("Error in Post : ", error);
  }
});
