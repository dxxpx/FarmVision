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
app.use(express.json({ limit: '50mb' }));

var gemini_reply = "Loading";


app.listen(port, () => {
  console.log("sever is running on http://192.168.194.89:%d/api/data", port);
});

app.get("/api/data", (req, res) => {
  res.status(200).send("Hey, You are in my backend!!!");
});

