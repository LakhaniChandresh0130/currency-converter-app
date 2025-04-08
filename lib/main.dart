import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        primaryColor: const Color(0xFF8A2BE2), // BlueViolet color
        scaffoldBackgroundColor: Colors.white, // Clean background
      ),
      home: const CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController amountController = TextEditingController();
  String baseCurrency = "USD";
  String targetCurrency = "EUR";
  double? conversionRate;
  double? convertedAmount;
  String lastUpdate = "--:--";
  bool isLoading = false;

  final List<String> currencies = ["USD", "EUR", "GBP", "INR", "JPY", "CAD"];

  Future<void> fetchExchangeRate() async {
    if (amountController.text.isEmpty) return;
    setState(() => isLoading = true);

    final url = Uri.parse(
        "http://localhost:5000/convert?base=$baseCurrency&to=$targetCurrency&amount=${amountController.text}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversionRate = data["rate"];
          convertedAmount = data["converted"];
          lastUpdate = DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(DateTime.fromMillisecondsSinceEpoch(data["lastUpdate"] * 1000));
        });
      } else {
        throw Exception("Failed to fetch exchange rate");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Currency Converter",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8A2BE2), // BlueViolet color
        elevation: 5,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset("assets/animation.json", fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text("Base:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: baseCurrency,
                        isExpanded: true,
                        items: currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => baseCurrency = value!);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text("To:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: targetCurrency,
                        isExpanded: true,
                        items: currencies.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => targetCurrency = value!);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter Amount",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading ? null : fetchExchangeRate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2BE2), // BlueViolet button
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Convert", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),

                const SizedBox(height: 20),

                if (convertedAmount != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$convertedAmount $targetCurrency",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Rate: $conversionRate",
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          "Last Update: $lastUpdate",
                          style: const TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: Container(
      //   color: const Color(0xFF8A2BE2), // BlueViolet footer background
      //   child: const Center(
      //     child: Text(
      //       "Copyright by Chandresh",
      //       style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),
    );
  }
}
