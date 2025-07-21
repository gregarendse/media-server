#!/usr/bin/env python3

import asyncio
import subprocess
import json
import sys
from typing import List, Dict, Any, Tuple

async def get_services_json() -> Dict[str, Any]:
    """Get services from kubectl as JSON."""
    try:
        process = await asyncio.create_subprocess_exec(
            "sudo", "k3s", "kubectl", "get", "services", "--all-namespaces", "--output=json",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()
        
        if process.returncode != 0:
            print(f"Error running kubectl command: {stderr.decode()}", file=sys.stderr)
            sys.exit(1)
            
        return json.loads(stdout.decode())
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON output: {e}", file=sys.stderr)
        sys.exit(1)

async def test_port_connectivity(cluster_ip: str, port_number: int, protocol: str) -> bool:
    """Test connectivity to a single port."""
    if protocol == "TCP":
        cmd = ["nc", "-zv", "-w", "3", str(cluster_ip), str(port_number)]
    elif protocol == "UDP":
        cmd = ["nc", "-vu", "-w", "3", str(cluster_ip), str(port_number)]
    else:
        return False
    
    try:
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        await process.communicate()
        return process.returncode == 0
    except Exception:
        return False

async def test_service_port(service_data: Tuple[str, str, str, str, int, str]) -> Tuple[str, str, str, str, int, str]:
    """Test a service port 3 times concurrently."""
    name, namespace, cluster_ip, port_name, port_number, port_protocol = service_data
    
    if port_protocol not in ["TCP", "UDP"]:
        return name, namespace, cluster_ip, port_name, port_number, f"0/3 (Unknown protocol: {port_protocol})"
    
    # Run 3 tests concurrently
    tasks = [
        test_port_connectivity(cluster_ip, port_number, port_protocol)
        for _ in range(3)
    ]
    
    results = await asyncio.gather(*tasks, return_exceptions=True)
    success_count = sum(1 for result in results if result is True)
    
    return name, namespace, cluster_ip, port_name, port_number, f"{success_count}/3"

def truncate(val: Any, max_width: int = 30) -> str:
    """Truncate string to max width."""
    val = str(val)
    if len(val) > max_width:
        return val[:max_width-3] + "..."
    return val

def print_results(results: List[Tuple[str, str, str, str, int, str]]) -> None:
    """Print results in a formatted table."""
    MAX_COL_WIDTH = 30
    
    # Print header
    headers = ["Service", "Namespace", "ClusterIP", "Port Name", "Port", "Result"]
    print(
        truncate("Service", MAX_COL_WIDTH).ljust(MAX_COL_WIDTH),
        " | " + truncate("Namespace", MAX_COL_WIDTH).ljust(MAX_COL_WIDTH),
        " | " + truncate("ClusterIp", 15).ljust(15),
        " | " + truncate("Port Name", MAX_COL_WIDTH).ljust(MAX_COL_WIDTH),
        " | " + truncate("Port", 6).ljust(6),
        " | " + truncate("Result", 6).ljust(6)
    )
    print(
        "-" * MAX_COL_WIDTH,
        "-+-" + "-" * MAX_COL_WIDTH,
        "-+-" + "-" * 15,
        "-+-" + "-" * MAX_COL_WIDTH,
        "-+-" + "-" * 6,
        "-+-" + "-" * 6
    )
    # print("-+-".join("-" * MAX_COL_WIDTH for _ in headers))
    
    # Print results
    for name, namespace, cluster_ip, port_name, port_number, success in results:
        print(
            truncate(name, MAX_COL_WIDTH).ljust(MAX_COL_WIDTH),
            " | " + truncate(namespace, MAX_COL_WIDTH).ljust(MAX_COL_WIDTH),
            " | " + truncate(cluster_ip, 15).ljust(15),
            " | " + truncate(port_name or "N/A", MAX_COL_WIDTH).ljust(MAX_COL_WIDTH),
            " | " + truncate(port_number, 6).ljust(6),
            " | " + truncate(success, 6).ljust(6)
        )
        # row = [
        #     truncate(name, MAX_COL_WIDTH),
        #     truncate(namespace, MAX_COL_WIDTH),
        #     truncate(cluster_ip, 15),
        #     truncate(port_name or "N/A", MAX_COL_WIDTH),
        #     truncate(port_number, 6),
        #     truncate(success, 6)
        # ]
        # print(" | ".join(str(col).ljust(MAX_COL_WIDTH) for col in row))

async def main():
    """Main async function."""
    services_json = await get_services_json()
    
    # Collect all service port data
    service_port_data = []
    for item in services_json.get("items", []):
        metadata = item.get("metadata", {})
        spec = item.get("spec", {})
        name = metadata.get("name")
        namespace = metadata.get("namespace")
        cluster_ip = spec.get("clusterIP")
        
        # Skip services without cluster IP or with None/empty cluster IP
        if not cluster_ip or cluster_ip in ["None", ""]:
            continue
            
        for port in spec.get("ports", []):
            port_name = port.get("name")
            port_number = port.get("port")
            port_protocol = port.get("protocol")
            
            service_port_data.append((
                name, namespace, cluster_ip, port_name, port_number, port_protocol
            ))
    
    if not service_port_data:
        print("No services with valid cluster IPs found.")
        return
    
    print(f"Testing connectivity to {len(service_port_data)} service ports...")
    
    # Run all tests concurrently
    tasks = [test_service_port(data) for data in service_port_data]
    results = await asyncio.gather(*tasks)
    
    # Print results
    print_results(results)

if __name__ == "__main__":
    asyncio.run(main())
