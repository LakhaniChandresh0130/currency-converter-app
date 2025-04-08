const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(cors());

const API_KEY = "fpudu755clgs8l7cgh5bp74lueinqmasctkricigsem1hk3ut58";

app.get('/convert', async (req, res) => {
    const { base, to, amount } = req.query;
    try {
        const response = await axios.get(
            `https://anyapi.io/api/v1/exchange/convert?base=${base}&to=${to}&amount=${amount}&apiKey=${API_KEY}`
        );
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to fetch data" });
    }
});

app.listen(5000, () => console.log("Server running on port 5000"));
