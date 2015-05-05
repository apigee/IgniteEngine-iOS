<?php

function remap($array)
{
	if (!is_array($array))
		return;
	else
	{
		$i = 0;
		$return = [];
		foreach ($array as $key => $value)
		{
			//$array[$key] = $key;
			$array[$key]['id'] = $key;
			array_push($return, $array[$key]);
			$i++;
		}
		//print_r($return);
		return $return;
	}
}

function process($value, $key)
{
	if (in_array($value, ['Yes', 'YES', 'yes', 'true', 'True', 'TRUE']))
		return true;
	if (in_array($value, ['No', 'NO', 'no', 'false', 'False', 'FALSE']))
		return false;
	if (is_numeric($value))
	{
		if (in_array($key, array("padding", "margin")))
			return array(
				"top"=>$value,
				"right"=>$value,
				"bottom"=>$value,
				"left"=>$value
			);
		else
			return floatval($value);
	}
	else
		return $value;
}

function parse($array, $attr = "")
{
	if (!is_array($array)) 
	{
		return process($array, $attr);
	}

	foreach ($array as $key => $value) 
	{
		$array[$key] = parse($value, $key);
		if ($key === "controls")
		{
			$array['controls'] = remap($array['controls']);
		}
	}
	return $array;
}

//output

if (isset($argv[1]))
{
	$filename = $argv[1];
}
else
{
	echo "You need to specify the file to parse as an argument, for example: 'php script.php myFile.json'.\n";
	$filename = "format_1.2.json";
}

$json = json_decode(file_get_contents($filename), true);
$output = pathinfo($filename);
$output = $output['dirname']."/".$output['filename']."_parsed.".$output['extension'];
file_put_contents($output, json_encode(parse($json), JSON_PRETTY_PRINT));



?>