import { GoogleGenerativeAI } from "@google/generative-ai";
import { Console } from "console";
import fs from "fs";
const genAI = new GoogleGenerativeAI("AIzaSyBdM-zkMxxQhCkvept_nv0BIXtUTEwTOZ8");
import { createRequire } from "module";
const require = createRequire(import.meta.url);
const http = require("node:http");
const express = require("express");
const app = express();
import multer from "multer";
const port = 3000;
const { Server } = require("ws");
app.use(express.json({ limit: '50mb' }));

const upload = multer({
    dest: "uploads/", limits: {
        fileSize: 50 * 1024 * 1024
    }
});

var gemini_reply = "Loading";
async function GeminiAi(params, imagePath) {
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

        const imageBuffer = fs.readFileSync(imagePath);
        const prompt = `${params}\nImage data: ${imageBuffer.toString('base64')}`;

        const result = await model.generateContent(prompt);
        const response = await result.response;

        gemini_reply = await response.text();

        const jsonString = gemini_reply.replace(/```json|```/g, '').trim();

        const jsonBody = JSON.parse(jsonString);

        var diseaseInfo = {
            name: jsonBody.name || "Not Identified",
            symptoms: jsonBody.symptoms ? jsonBody.symptoms.join(', ') : "Not Listed",
            precautions: jsonBody.precautions ? jsonBody.precautions.join(', ') : "Not Listed",
            treatments: jsonBody.treatments ? jsonBody.treatments.join(', ') : "Not Listed",
            causes: jsonBody.causes ? jsonBody.causes.join(', ') : "Not Defined",
            medicines: jsonBody.medicines ? jsonBody.medicines.join(', ') : "Not defined",
            pesticides: jsonBody.pesticides ? jsonBody.pesticides.join(', ') : "Not identified"
        }

        console.log(response.text());
        return diseaseInfo;
    } catch (error) {
        console.log("Error inside GeminiAI function : ", error);
        throw error;
    }
}

async function GeminiChatBot(params) {
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
    console.log("sever is running on http://192.168.194.89:%d/", port);
});

app.get("/", (req, res) => {
    res.status(200).send("Hey, You are in my backend!!!");
});

app.post("/api/data", upload.single('image'), async (req, res) => {
    try {
        console.log("Request from app : ", req.body);
        const user_prompt = req.body.prompt;
        const image = req.file;
        if (!user_prompt) {
            throw new Error("No prompt provided");
        }
        if (image) {
            console.log("Image uploaded: ", image.path);
        } else {
            console.log("No image uploaded");
            res.status(400).json({
                success: false,
                message: "No image uploaded. Please provide the image."
            });
            return;
        }
        const reply_from_gemini = await GeminiAi(user_prompt, image.path);


        res.status(200).json({
            success: true,
            status_code: 200,
            name: reply_from_gemini.name,
            symptoms: reply_from_gemini.symptoms,
            precautions: reply_from_gemini.precautions,
            treatments: reply_from_gemini.treatments,
            causes: reply_from_gemini.causes,
            medicines: reply_from_gemini.medicines,
            pesticides: reply_from_gemini.pesticides,
            user_prompt: req.body,
        });
        console.log("Response is : " + reply_from_gemini.body);

    } catch (error) {
        console.log("Error in Post : ", error);
        res.status(500).json({
            success: false,
            message: "Error processing request",
        });
    }
});

app.post("/chatbot", async (req, res) => {
    try {
        console.log("Request from app : ", req.body);
        const user_prompt = req.body.prompt;
        if (!user_prompt) {
            throw new Error("No prompt provided");
        }

        await GeminiChatBot(user_prompt);

        res.status(200).json({
            success: true,
            status_code: 200,
            message: gemini_reply,
            user_prompt: req.body,
        });
    } catch (error) {
        console.log("Error in Post : ", error);
        res.status(500).json({
            success: false,
            message: "Error processing request",
        });
    }
});