import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'firebase_service.dart';
class SignUp extends StatelessWidget {
  SignUp({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1F22),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/textures/logo.png',
                height: 200,
              ),
              TextFormField(
                cursorColor: Color(0xFF15EED2),
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',

                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Color(0xFF2B2D30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF15EED2), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF2B2D30), width: 2),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: Color(0xFF15EED2),
                      controller: _firstname,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: Color(0xFF2B2D30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF15EED2), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF2B2D30), width: 2),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      cursorColor: Color(0xFF15EED2),
                      controller: _lastname,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: Color(0xFF2B2D30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF15EED2), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF2B2D30), width: 2),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: 1,
                      dropdownColor:  Color(0xFF2B2D30),
                      decoration: InputDecoration(
                        labelText: 'Day',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color(0xFF2B2D30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onChanged: (value) {
                        _selectedDay = value;
                      },
                      items: List.generate(31, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: 1,
                      dropdownColor:  Color(0xFF2B2D30),
                      decoration: InputDecoration(
                        labelText: 'Month',
                        labelStyle: TextStyle(color: Color(0xFF2B2D30)),
                        filled: true,
                        fillColor: Color(0xFF2B2D30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onChanged: (value) {
                        _selectedMonth = value;
                      },
                      items: List.generate(12, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: 2000,
                      dropdownColor:  Color(0xFF2B2D30),
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color(0xFF2B2D30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onChanged: (value) {
                        _selectedYear = value;
                      },
                      items: List.generate(100, (index) {
                        int year = 2025 - index;
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(
                            '$year',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                cursorColor: Color(0xFF15EED2),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Color(0xFF2B2D30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF15ECD0), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF2B2D30), width: 2),
                  ),
                ),
                obscureText: true,
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextFormField(
                cursorColor: Color(0xFF15EED2),
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Color(0xFF2B2D30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF15ECD0), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF2B2D30), width: 2),
                  ),
                ),
                obscureText: true,
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AuthService().signup(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    confirmPassword: _confirmPasswordController.text.trim(),
                    firstname: _firstname.text.trim(),
                    lastname: _lastname.text.trim(),
                    day: _selectedDay,
                    month: _selectedMonth,
                    year: _selectedYear,
                    context: context,
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Color(0xFF15EED2),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
