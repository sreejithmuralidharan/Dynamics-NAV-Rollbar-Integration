param(
	$eventData,
	$eventLevel,
	$eventProvider,
    $eventRecordID

)
$eventType = $eventLevel;

switch ($eventLevel){
    4{
        $eventType  = "info";
    }

    3{
        $eventType  = "warning";
    }

    2{
        $eventType  = "error";
    }
}

$log_url = "http://requestbin.net/r/178iipa1";
$log_url1 = "https://api.rollbar.com/api/1/item/";
$messageObject = @{'body'= $eventProvider}
$serverObject = @{
    "event"=@{
    "event_id" = $eventRecordID;
	"provider" = $eventProvider;
	"level" = $eventType;
	"data" = $eventData;
	}
    "cpu"= "x64";
    "host"= [System.Net.Dns]::GetHostName()
    }

$system = Get-WmiObject win32_OperatingSystem
$totalPhysicalMem = $system.TotalVisibleMemorySize
$freePhysicalMem = $system.FreePhysicalMemory
$usedPhysicalMem = $totalPhysicalMem - $freePhysicalMem
$usedPhysicalMemPct = [math]::Round(($usedPhysicalMem / $totalPhysicalMem) * 100,1)

$customObject = @{
    "memory"=@{
        "used_memory"=$usedPhysicalMem;        
        "memory_usage"=$usedPhysicalMemPct 
    }

}

$jsonString = @{ 
    "data"=@{
        "environment"="Production";
        "server" = $serverObject;
        "custom" = $customObject;
         "telemetry"= @{
            "level"= $eventType
            };

                "body"=@{
                "message"=@{
                    "body" = $eventData
                }
        
        }
        };
    "access_token"="GET ACCESS TOKEN FROM ROLLBAR"

}
$newString = ConvertTo-json $jsonString -Depth 10


Invoke-WebRequest -Uri $log_url1 -Method POST -Body $newString