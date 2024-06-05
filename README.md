# mre-translations-missing-namespace-of-applications

> When retrieving `Translations` from a Source-Tracked Org, the `<customApplications>` entries are missing the namespacePrefix of Apps from Managed Packages (e.g. [Address Picker Autocomplete for Flow](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FKAgjUAH)).
>
> As a consequence the deployment of those invalid `.translation-meta.xml` files to another org fails with:
>
> `In field: name - no CustomApplication named Address_Picker_Autocomplete found`

[![Actions Status](https://github.com/mdapi-issues/mre-translations-missing-namespace-of-applications/actions/workflows/default.yml/badge.svg?branch=main)](https://github.com/mdapi-issues/mre-translations-missing-namespace-of-applications/actions?query=branch:main)

> [!IMPORTANT]
> A green status badge means the issue was successfully reproduced.
>
> A red status badge means the issue was fixed or the pipeline failed for another reason.

actual (red) vs. expected (green)

```diff
<?xml version="1.0" encoding="UTF-8"?>
<Translations xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <customApplications>
        <description xsi:nil="true"/>
        <label><!-- Address Picker Autocomplete --></label>
-        <name>Address_Picker_Autocomplete</name>
+        <name>DV_Flow_AP__Address_Picker_Autocomplete</name>
    </customApplications>
</Translations>
```

## Instructions

```console
# create a Scratch Org with the Translation Workbench enabled
sf org create scratch -f config/project-scratch-def.json --alias translation-managed-application --set-default
# install the Managed Package "Address Picker Autocomplete for Flow"
sf package install --package 04t6F000004DJCEQA4 --no-prompt --wait 30
# deploy some unrelated translation of a managed CustomLabel
sf project deploy start --source-dir fixtures/some-unrelated-translation-of-a-managed-customlabel
# retrieve the translations from the Scratch Org
sf project retrieve start -m Translations
```

Test if the translations contain an entry for the `Address_Picker_Autocomplete` app without the namespace `DV_Flow_AP`:

```console
grep -r -B3 -A1 "<name>Address_Picker_Autocomplete</name>" force-app/main/default/translations
```

> [!CAUTION]
>
> Even worse: When having translated both the `description` and the `label` (here in German), the retrieved Translation will contain two `<customApplications>` entries having the same name:

```xml
    <customApplications>
        <description>Test Description DE</description>
        <name>Address_Picker_Autocomplete</name>
    </customApplications>
    <customApplications>
        <description xsi:nil="true"/>
        <label>Test Label DE</label>
        <name>Address_Picker_Autocomplete</name>
    </customApplications>
```

```console
sf project deploy start -d fixtures/actually-translating-the-managed-app
sf project retrieve start -m Translations
grep -r -B3 -A1 "<name>Address_Picker_Autocomplete</name>" force-app/main/default/translations
```

### Further information

Here's the `FileProperties` information retrieved using the `listMetadata()` call:

```console
$ sf org list metadata -m CustomApplication | grep -e 'fullName.*Address_Picker_Autocomplete' -B 5 -A 8
  {
    "createdById": "0055t000005TaGmAAK",
    "createdByName": "User User",
    "createdDate": "2024-06-05T12:42:44.000Z",
    "fileName": "applications/DV_Flow_AP__Address_Picker_Autocomplete.app",
    "fullName": "DV_Flow_AP__Address_Picker_Autocomplete",
    "id": "02u5t000000eW3dAAE",
    "lastModifiedById": "0055t000005TaGmAAK",
    "lastModifiedByName": "User User",
    "lastModifiedDate": "2024-06-05T12:42:44.000Z",
    "manageableState": "installed",
    "namespacePrefix": "DV_Flow_AP",
    "type": "CustomApplication"
  },
```
