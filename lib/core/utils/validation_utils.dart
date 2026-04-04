import 'dart:core';
import 'package:flutter/material.dart';

/// Validation utilities for form inputs
class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    if (value.length > 100) {
      return 'Email cannot exceed 100 characters';
    }
    
    return null;
  }
  
  // Phone number validation (Nepal format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Nepal phone numbers are 10 digits (including area code)
    if (!RegExp(r'^9[6-8]\d{8}$').hasMatch(cleanPhone)) {
      return 'Please enter a valid Nepal phone number';
    }
    
    if (cleanPhone.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (value.length > 128) {
      return 'Password cannot exceed 128 characters';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 50) {
      return 'Username cannot exceed 50 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, dots, hyphens, and underscores';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (value.length > 100) {
      return '$fieldName cannot exceed 100 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value)) {
      return '$fieldName can only contain letters, spaces, and dots';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Number validation
  static String? validateNumber(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  // Positive number validation
  static String? validatePositiveNumber(String? value, {String fieldName = 'Field'}) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    if (double.parse(value!) <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }
  
  // Integer validation
  static String? validateInteger(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (int.tryParse(value) == null) {
      return 'Please enter a valid whole number';
    }
    
    return null;
  }
  
  // Positive integer validation
  static String? validatePositiveInteger(String? value, {String fieldName = 'Field'}) {
    final intError = validateInteger(value, fieldName: fieldName);
    if (intError != null) return intError;
    
    if (int.parse(value!) <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }
  
  // Range validation
  static String? validateRange(
    String? value, {
    required double min,
    required double max,
    String fieldName = 'Field',
  }) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    final number = double.parse(value!);
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }
    
    return null;
  }
  
  // Length validation
  static String? validateLength(
    String? value, {
    required int minLength,
    required int maxLength,
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    
    return null;
  }
  
  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    
    if (value.length > 500) {
      return 'Address cannot exceed 500 characters';
    }
    
    return null;
  }
  
  // ZIP code validation (Nepal)
  static String? validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ZIP code is required';
    }
    
    // Nepal postal codes are 5 digits
    if (!RegExp(r'^\d{5}$').hasMatch(value.trim())) {
      return 'Please enter a valid Nepal ZIP code (5 digits)';
    }
    
    return null;
  }
  
  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    
    if (!RegExp(r'^https?://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$').hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // Date validation
  static String? validateDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (value.isAfter(DateTime.now())) {
      return '$fieldName cannot be in the future';
    }
    
    if (value.isBefore(DateTime(1900))) {
      return '$fieldName cannot be before 1900';
    }
    
    return null;
  }
  
  // Future date validation
  static String? validateFutureDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (value.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }
    
    return null;
  }
  
  // Age validation
  static String? validateAge(DateTime? birthDate, {int minAge = 18, int maxAge = 120}) {
    if (birthDate == null) {
      return 'Birth date is required';
    }
    
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    
    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }
    
    if (age > maxAge) {
      return 'Age cannot exceed $maxAge years';
    }
    
    return null;
  }
  
  // Quantity validation
  static String? validateQuantity(String? value, {int minQuantity = 0, int maxQuantity = 999999}) {
    final intError = validatePositiveInteger(value, fieldName: 'Quantity');
    if (intError != null) return intError;
    
    final quantity = int.parse(value!);
    if (quantity < minQuantity) {
      return 'Quantity must be at least $minQuantity';
    }
    
    if (quantity > maxQuantity) {
      return 'Quantity cannot exceed $maxQuantity';
    }
    
    return null;
  }
  
  // Price validation
  static String? validatePrice(String? value, {double minPrice = 0.0, double maxPrice = 999999.99}) {
    final numberError = validatePositiveNumber(value, fieldName: 'Price');
    if (numberError != null) return numberError;
    
    final price = double.parse(value!);
    if (price < minPrice) {
      return 'Price must be at least ${minPrice.toStringAsFixed(2)}';
    }
    
    if (price > maxPrice) {
      return 'Price cannot exceed ${maxPrice.toStringAsFixed(2)}';
    }
    
    // Check for valid decimal places (max 2)
    if (value.contains('.') && value.split('.')[1].length > 2) {
      return 'Price cannot have more than 2 decimal places';
    }
    
    return null;
  }
  
  // Percentage validation
  static String? validatePercentage(String? value, {double minPercentage = 0.0, double maxPercentage = 100.0}) {
    final numberError = validateNumber(value, fieldName: 'Percentage');
    if (numberError != null) return numberError;
    
    final percentage = double.parse(value!);
    if (percentage < minPercentage || percentage > maxPercentage) {
      return 'Percentage must be between $minPercentage and $maxPercentage';
    }
    
    return null;
  }
  
  // VAT number validation (Nepal)
  static String? validateVatNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'VAT number is required';
    }
    
    // Nepal VAT numbers are 9 digits (for individuals) or 13 digits (for companies)
    if (!RegExp(r'^\d{9}$|^\d{13}$').hasMatch(value.trim())) {
      return 'Please enter a valid Nepal VAT number (9 or 13 digits)';
    }
    
    return null;
  }
  
  // PAN number validation (Nepal)
  static String? validatePanNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }
    
    // Nepal PAN numbers are 9 digits
    if (!RegExp(r'^\d{9}$').hasMatch(value.trim())) {
      return 'Please enter a valid Nepal PAN number (9 digits)';
    }
    
    return null;
  }
  
  // Batch number validation
  static String? validateBatchNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Batch number is required';
    }
    
    if (value.length < 3) {
      return 'Batch number must be at least 3 characters';
    }
    
    if (value.length > 50) {
      return 'Batch number cannot exceed 50 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value)) {
      return 'Batch number can only contain letters, numbers, and hyphens';
    }
    
    return null;
  }
  
  // HSN code validation
  static String? validateHsnCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'HSN code is required';
    }
    
    // HSN codes are typically 8 digits
    if (!RegExp(r'^\d{8}$').hasMatch(value.trim())) {
      return 'Please enter a valid HSN code (8 digits)';
    }
    
    return null;
  }
  
  // Private constructor to prevent instantiation
  ValidationUtils._();
}
