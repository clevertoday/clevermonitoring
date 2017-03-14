#!/usr/bin/env node

const fs = require('fs');
const express = require('express');
const bodyParser = require('body-parser')
const app = express();
const sys = require('util')
const spawn = require('child_process').spawn;
const xml2json = require('xml-to-json')

const arachni = '/arachni-1.5-0.5.11/bin/arachni';
const arachniReporter = '/arachni-1.5-0.5.11/bin/arachni_reporter';

function startPenTest(url) {
  return new Promise((resolve, reject) => {
    console.log(`Starting scan of ${url}`);

    const reportName = Date.now() + '_' + url.replace('://', '');
    const args = [
      url,
      '--checks=xss,common_admin_interfaces,insecure_cross_domain_policy_access,insecure_cookies,password_autocomplete,unencrypted_password_forms,insecure_cors_policy,emails,html_objects,credit_card,sql_injection,file_inclusion,code_injection',
      '--scope-exclude-binaries',
      '--scope-directory-depth-limit=10',   // Default infinite
      '--scope-page-limit=75',              // Default infinite
      '--output-only-positives',
      '--audit-links',
      '--audit-cookies',
      '--audit-forms',
      '--audit-headers',
      '--audit-ui-inputs',
      '--audit-ui-forms',
      '--http-ssl-verify-host',
      //'--timeout=0:0:0',
      `--report-save-path=/reports/${reportName}.afr`
    ];
    console.log(`Executing command ${arachni} with args ${args}`);

    const command = spawn(arachni, args);

    command.stdout.on('data', (data) => {
      console.log(`stdout: ${data}`);
    });

    command.stderr.on('data', (data) => {
      console.log(`stderr: ${data}`);
    });

    command.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
      resolve(reportName);
    });

    command.on('error', (err) => {
      reject(err);
    });
  });
}

function generateXmlReport(reportName) {
  return new Promise((resolve, reject) => {
    console.log(`Generating XML report of file ${reportName}.afr...`);

    const args = [
      `/reports/${reportName}.afr`,
      `--reporter=xml:outfile=/reports/${reportName}.xml`
    ];
    console.log(`Executing command ${arachniReporter} with args ${args}`);

    const command = spawn(arachniReporter, args);

    command.stdout.on('data', (data) => {
      console.log(`stdout: ${data}`);
    });

    command.stderr.on('data', (data) => {
      console.log(`stderr: ${data}`);
    });

    command.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
      resolve(reportName);
    });

    command.on('error', (err) => {
      reject(err);
    });
  });
}

function convertReportToJson(reportName) {
  return new Promise((resolve, reject) => {
    xml2json({
      input: `/reports/${reportName}.xml`,
      output: null
    }, (err, result) => {
      if (err) {
        reject(err);
      } else {
        if (result.report && result.report.issues && typeof result.report.issues !== 'string') {
          result.report.issues = result.report.issues.map(issue => {
            return Object.assign({}, issue, {
              page: undefined,
              response: Object.assign({}, issue.response, {
                body: undefined
              })
            });
          });
        }
        resolve(result);
      }
    });
  });
}

app.use(bodyParser.json()); 

app.post('/', (req, res) => {
  console.log('Received request');
  const url = req.body.url;

  if (url) {
    startPenTest(url).then(reportName => {
      return generateXmlReport(reportName);
    }).then(reportName => {
      return convertReportToJson(reportName);
    }).then(report => {
      res.send(report);
    }).catch(err => {
      res.status(500);
      res.send(err);
    });
  } else {
    res.status(400);
    res.send('Missing url parameter in payload');
  }
});

app.listen(3000, () => {
  console.log('Express started; listening on port 3000');
});
