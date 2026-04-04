#!/usr/bin/env python3
"""
Comprehensive Test Report Generator for VedantaTrade
Generates detailed HTML, JSON, and PDF reports from test results
"""

import os
import sys
import json
import argparse
from datetime import datetime
from pathlib import Path
from jinja2 import Template
import subprocess

class TestReportGenerator:
    def __init__(self, output_dir="test-reports"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
        self.test_results = {
            'unit_tests': {},
            'widget_tests': {},
            'integration_tests': {},
            'performance_tests': {},
            'security_tests': {},
            'accessibility_tests': {},
            'localization_tests': {},
            'e2e_tests': {}
        }
        
        self.summary = {
            'total_tests': 0,
            'passed': 0,
            'failed': 0,
            'skipped': 0,
            'coverage': 0.0,
            'duration': 0.0,
            'timestamp': datetime.now().isoformat()
        }

    def collect_test_results(self):
        """Collect test results from various sources"""
        print("Collecting test results...")
        
        # Collect unit test results
        self._collect_json_results('unit-test-results-*', 'unit_tests')
        
        # Collect widget test results
        self._collect_json_results('widget-test-results-*', 'widget_tests')
        
        # Collect integration test results
        self._collect_json_results('integration-test-results-*', 'integration_tests')
        
        # Collect performance test results
        self._collect_json_results('performance-test-results-*', 'performance_tests')
        
        # Collect security test results
        self._collect_json_results('security-test-results', 'security_tests')
        
        # Collect accessibility test results
        self._collect_json_results('accessibility-test-results', 'accessibility_tests')
        
        # Collect localization test results
        self._collect_json_results('localization-test-results-*', 'localization_tests')
        
        # Collect E2E test results
        self._collect_json_results('e2e-test-results-*', 'e2e_tests')

    def _collect_json_results(self, pattern, test_type):
        """Collect JSON test results matching a pattern"""
        import glob
        
        for file_path in glob.glob(f"{pattern}/*.json"):
            try:
                with open(file_path, 'r') as f:
                    data = json.load(f)
                    self.test_results[test_type][file_path] = data
                    self._update_summary(data)
            except Exception as e:
                print(f"Error reading {file_path}: {e}")

    def _update_summary(self, test_data):
        """Update summary statistics"""
        if 'tests' in test_data:
            tests = test_data['tests']
            self.summary['total_tests'] += len(tests)
            
            for test in tests:
                if test.get('result') == 'success':
                    self.summary['passed'] += 1
                elif test.get('result') == 'failure':
                    self.summary['failed'] += 1
                elif test.get('result') == 'skipped':
                    self.summary['skipped'] += 1
        
        if 'coverage' in test_data:
            self.summary['coverage'] = max(self.summary['coverage'], test_data['coverage'])
        
        if 'duration' in test_data:
            self.summary['duration'] += test_data['duration']

    def generate_html_report(self):
        """Generate HTML test report"""
        print("Generating HTML report...")
        
        html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VedantaTrade Test Report</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e0e0e0;
        }
        .header h1 {
            color: #2c3e50;
            margin: 0;
            font-size: 2.5em;
        }
        .header p {
            color: #7f8c8d;
            margin: 10px 0 0 0;
            font-size: 1.1em;
        }
        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .summary-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .summary-card.success {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        .summary-card.warning {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .summary-card.info {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        .summary-card h3 {
            margin: 0 0 10px 0;
            font-size: 1.2em;
        }
        .summary-card .value {
            font-size: 2em;
            font-weight: bold;
        }
        .test-section {
            margin-bottom: 30px;
        }
        .test-section h2 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .test-item {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 10px;
        }
        .test-item.passed {
            border-left: 4px solid #28a745;
        }
        .test-item.failed {
            border-left: 4px solid #dc3545;
        }
        .test-item.skipped {
            border-left: 4px solid #ffc107;
        }
        .test-name {
            font-weight: bold;
            color: #2c3e50;
        }
        .test-status {
            float: right;
            padding: 2px 8px;
            border-radius: 3px;
            color: white;
            font-size: 0.8em;
        }
        .test-status.passed {
            background: #28a745;
        }
        .test-status.failed {
            background: #dc3545;
        }
        .test-status.skipped {
            background: #ffc107;
        }
        .coverage-bar {
            width: 100%;
            height: 20px;
            background: #e9ecef;
            border-radius: 10px;
            overflow: hidden;
            margin: 10px 0;
        }
        .coverage-fill {
            height: 100%;
            background: linear-gradient(90deg, #28a745, #20c997);
            transition: width 0.3s ease;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧪 VedantaTrade Test Report</h1>
            <p>Generated on {{ timestamp }} | Branch: {{ branch }}</p>
        </div>

        <div class="summary">
            <div class="summary-card info">
                <h3>Total Tests</h3>
                <div class="value">{{ total_tests }}</div>
            </div>
            <div class="summary-card success">
                <h3>Passed</h3>
                <div class="value">{{ passed }}</div>
            </div>
            <div class="summary-card warning">
                <h3>Failed</h3>
                <div class="value">{{ failed }}</div>
            </div>
            <div class="summary-card info">
                <h3>Coverage</h3>
                <div class="value">{{ coverage }}%</div>
            </div>
        </div>

        <div class="test-section">
            <h2>📊 Test Coverage</h2>
            <div class="coverage-bar">
                <div class="coverage-fill" style="width: {{ coverage }}%"></div>
            </div>
            <p>Code Coverage: {{ coverage }}%</p>
        </div>

        {% for test_type, results in test_results.items() %}
        <div class="test-section">
            <h2>{{ test_type|title }}</h2>
            {% for file_path, data in results.items() %}
            {% if 'tests' in data %}
            {% for test in data.tests %}
            <div class="test-item {{ test.result }}">
                <span class="test-name">{{ test.name }}</span>
                <span class="test-status {{ test.result }}">{{ test.result|upper }}</span>
                {% if test.duration %}
                <p><small>Duration: {{ test.duration }}s</small></p>
                {% endif %}
                {% if test.error %}
                <p><small>Error: {{ test.error }}</small></p>
                {% endif %}
            </div>
            {% endfor %}
            {% endif %}
            {% endfor %}
        </div>
        {% endfor %}

        <div class="footer">
            <p>Report generated by VedantaTrade CI/CD Pipeline</p>
        </div>
    </div>
</body>
</html>
        """
        
        template = Template(html_template)
        
        # Get current branch
        try:
            branch = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).decode().strip()
        except:
            branch = 'unknown'
        
        html_content = template.render(
            timestamp=self.summary['timestamp'],
            branch=branch,
            total_tests=self.summary['total_tests'],
            passed=self.summary['passed'],
            failed=self.summary['failed'],
            coverage=f"{self.summary['coverage']:.1f}",
            test_results=self.test_results
        )
        
        with open(self.output_dir / 'index.html', 'w') as f:
            f.write(html_content)
        
        print(f"HTML report generated: {self.output_dir / 'index.html'}")

    def generate_json_report(self):
        """Generate JSON test report"""
        print("Generating JSON report...")
        
        report_data = {
            'summary': self.summary,
            'test_results': self.test_results,
            'metadata': {
                'generator': 'VedantaTrade Test Report Generator',
                'version': '1.0.0',
                'timestamp': datetime.now().isoformat(),
                'environment': os.environ.get('ENVIRONMENT', 'unknown')
            }
        }
        
        with open(self.output_dir / 'report.json', 'w') as f:
            json.dump(report_data, f, indent=2, default=str)
        
        print(f"JSON report generated: {self.output_dir / 'report.json'}")

    def generate_pdf_report(self):
        """Generate PDF test report"""
        print("Generating PDF report...")
        
        try:
            # Try to use weasyprint for PDF generation
            import weasyprint
            
            html_file = self.output_dir / 'index.html'
            pdf_file = self.output_dir / 'report.pdf'
            
            if html_file.exists():
                weasyprint.HTML(filename=str(html_file)).write_pdf(str(pdf_file))
                print(f"PDF report generated: {pdf_file}")
            else:
                print("HTML report not found, skipping PDF generation")
                
        except ImportError:
            print("weasyprint not available, skipping PDF generation")
        except Exception as e:
            print(f"Error generating PDF: {e}")

    def generate_all_reports(self):
        """Generate all report formats"""
        print("Starting comprehensive test report generation...")
        
        self.collect_test_results()
        self.generate_html_report()
        self.generate_json_report()
        self.generate_pdf_report()
        
        print(f"All reports generated in: {self.output_dir}")

def main():
    parser = argparse.ArgumentParser(description='Generate comprehensive test reports')
    parser.add_argument('--output-dir', default='test-reports', help='Output directory for reports')
    parser.add_argument('--format', nargs='+', default=['html', 'json'], 
                       choices=['html', 'json', 'pdf'], help='Report formats to generate')
    
    args = parser.parse_args()
    
    generator = TestReportGenerator(args.output_dir)
    
    if 'html' in args.format:
        generator.collect_test_results()
        generator.generate_html_report()
    
    if 'json' in args.format:
        generator.collect_test_results()
        generator.generate_json_report()
    
    if 'pdf' in args.format:
        generator.collect_test_results()
        generator.generate_pdf_report()
    
    print("Test report generation completed!")

if __name__ == '__main__':
    main()
